// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<String> insertProfileWithDebug(
  String id,
  String firstname,
  String lastname,
  String? email,
  String phone,
  String role,
) async {
  try {
    final supabase = Supabase.instance.client;

    debugPrint('=== insertProfileWithDebug Called ===');
    debugPrint('ID: $id');
    debugPrint('First Name: $firstname');
    debugPrint('Last Name: $lastname');
    debugPrint('Email: $email');
    debugPrint('Phone: $phone');
    debugPrint('Role: $role');

    // Default empty role to 'client'
    final roleToUse = role.isEmpty ? 'client' : role;
    debugPrint('Role to use: $roleToUse');

    // Check if profile already exists (from auto-create trigger)
    debugPrint('--- Checking if profile already exists ---');
    final existingProfile = await supabase
        .from('profiles')
        .select('id, phone_number, email')
        .eq('id', id)
        .maybeSingle();

    if (existingProfile != null) {
      debugPrint('Profile exists from auto-create trigger, performing UPDATE');

      // Profile exists, update it with complete data
      final Map<String, dynamic> updateData = {
        'first_name': firstname,
        'last_name': lastname,
        'display_name': '$firstname $lastname'.trim(),
        'phone_number': phone,
        'role': roleToUse,
      };

      if (email != null && email.isNotEmpty) {
        updateData['email'] = email;
      }

      await supabase.from('profiles').update(updateData).eq('id', id);
      debugPrint('Profile updated successfully');
      return "success";
    }

    debugPrint('Profile does not exist, performing INSERT');

    // Profile doesn't exist, proceed with validations and insert

    // Validation: Check if Phone already exists
    final phoneCheck = await supabase
        .from('profiles')
        .select('id')
        .eq('phone_number', phone)
        .maybeSingle();

    if (phoneCheck != null) {
      debugPrint('Error: Phone number already registered');
      return "Error: This phone number is already registered.";
    }

    // Validation: Check if Email already exists (only if email is provided)
    if (email != null && email.isNotEmpty) {
      final emailCheck = await supabase
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (emailCheck != null) {
        debugPrint('Error: Email already in use');
        return "Error: This email address is already in use.";
      }
    }

    // Prepare data for insert
    final Map<String, dynamic> data = {
      'id': id,
      'first_name': firstname,
      'last_name': lastname,
      'display_name': '$firstname $lastname'.trim(),
      'phone_number': phone,
      'role': roleToUse,
    };

    if (email != null && email.isNotEmpty) {
      data['email'] = email;
    }

    // Perform Insert
    debugPrint('Inserting new profile');
    await supabase.from('profiles').insert(data);
    debugPrint('Profile inserted successfully');

    return "success";
  } catch (e) {
    debugPrint('Database Error: $e');
    return "Database Error: ${e.toString()}";
  }
}
