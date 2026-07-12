// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
import '/api/resources/users_api.dart';
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
    debugPrint('=== insertProfileWithDebug Called ===');
    debugPrint('ID: $id');
    debugPrint('First Name: $firstname');
    debugPrint('Last Name: $lastname');
    debugPrint('Email: $email');
    debugPrint('Phone: $phone');
    debugPrint('Role: $role');

    final roleToUse = role.isEmpty ? 'client' : role;
    debugPrint('Role to use: $roleToUse');

    // Use SHPH API to update/create user profile
    final data = <String, dynamic>{
      'first_name': firstname,
      'last_name': lastname,
      'display_name': '$firstname $lastname'.trim(),
      'phone_number': phone,
      'role': roleToUse,
    };

    if (email != null && email.isNotEmpty) {
      data['email'] = email;
    }

    try {
      await ShphUsersApi.instance.updateMe(data);
      debugPrint('Profile updated via SHPH API successfully');
      return "success";
    } catch (apiError) {
      debugPrint('SHPH API update failed, falling back to Supabase: $apiError');
    }

    // Fallback: use Supabase directly
    final supabase = Supabase.instance.client;

    final existingProfile = await supabase
        .from('profiles')
        .select('id, phone_number, email')
        .eq('id', id)
        .maybeSingle();

    if (existingProfile != null) {
      debugPrint('Profile exists, performing UPDATE via Supabase');
      await supabase.from('profiles').update(data).eq('id', id);
      debugPrint('Profile updated successfully via Supabase');
      return "success";
    }

    debugPrint('Profile does not exist, performing INSERT via Supabase');

    final phoneCheck = await supabase
        .from('profiles')
        .select('id')
        .eq('phone_number', phone)
        .maybeSingle();

    if (phoneCheck != null) {
      debugPrint('Error: Phone number already registered');
      return "Error: This phone number is already registered.";
    }

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

    final Map<String, dynamic> insertData = {
      'id': id,
      'first_name': firstname,
      'last_name': lastname,
      'display_name': '$firstname $lastname'.trim(),
      'phone_number': phone,
      'role': roleToUse,
    };

    if (email != null && email.isNotEmpty) {
      insertData['email'] = email;
    }

    await supabase.from('profiles').insert(insertData);
    debugPrint('Profile inserted successfully via Supabase');

    return "success";
  } catch (e) {
    debugPrint('Database Error: $e');
    return "Database Error: ${e.toString()}";
  }
}
