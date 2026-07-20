// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

Future<List<String>?> scanDocument() async {
  // Configuration for ID/Document scanning
  final options = DocumentScannerOptions(
    documentFormats: {DocumentFormat.jpeg},
    mode: ScannerMode.full, // Provides editing/cropping UI
    isGalleryImport: true,
    pageLimit: 1, // Set to 1 for ID cards, higher for multi-page docs
  );

  final documentScanner = DocumentScanner(options: options);

  try {
    // This triggers the native system UI
    final DocumentScanningResult result = await documentScanner.scanDocument();

    // Return the list of file paths (images)
    return result.images;
  } catch (e) {
    // Handle user cancellation or permissions error
    print("Scanner Error: $e");
    return null;
  } finally {
    // Clean up the scanner instance
    documentScanner.close();
  }
}
