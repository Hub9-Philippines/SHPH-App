// Automatic FlutterFlow imports
import '/api/resources/users_api.dart';
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
    debugPrint('=== insertProfileWithDebug Called ===');
    debugPrint('ID: $id');
    debugPrint('First Name: $firstname');
    debugPrint('Last Name: $lastname');
    debugPrint('Email: $email');
    debugPrint('Phone: $phone');
    debugPrint('Role: $role');

    final roleToUse = role.isEmpty ? 'client' : role;
    debugPrint('Role to use: $roleToUse');

    final Map<String, dynamic> data = {
      'first_name': firstname,
      'last_name': lastname,
      'display_name': '$firstname $lastname'.trim(),
      'phone_number': phone,
      'role': roleToUse,
    };

    if (email != null && email.isNotEmpty) {
      data['email'] = email;
    }

    debugPrint('Updating profile via SHPH API');
    await ShphUsersApi.instance.updateMe(data);
    debugPrint('Profile updated successfully');
    return "success";
  } catch (e) {
    debugPrint('Database Error: $e');
    return "Database Error: ${e.toString()}";
  }
}
