// Automatic FlutterFlow imports

import '/backend/supabase/supabase.dart';
import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

Future<String?> uploadScannedFile(String filePath) async {
  try {
    File file = File(filePath);
    String fileName = 'id_scans/${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload to Firebase Storage
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = ref.putFile(file);

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    return null;
  }
}
