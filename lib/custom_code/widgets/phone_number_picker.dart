// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/theme/app_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';

class PhoneNumberPicker extends StatefulWidget {
  const PhoneNumberPicker({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<PhoneNumberPicker> createState() => _PhoneNumberPickerState();
}

class _PhoneNumberPickerState extends State<PhoneNumberPicker> {
  late FocusNode myFocusNode;

  @override
  void initState() {
    super.initState();

    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: IntlPhoneField(
        autofocus: true,
        focusNode: myFocusNode,
        decoration: InputDecoration(
          labelText: 'Phone Number',
          counterText: '',
          border: OutlineInputBorder(
            borderSide: BorderSide(),
          ),
        ),
        languageCode: "en",
        initialCountryCode: 'PH',
        onChanged: (phone) {
          FFAppState().update(() {
            FFAppState().phone = phone.completeNumber;
          });
          // print(phone.completeNumber);
        },
        onCountryChanged: (country) {
          print('Country changed to: ' + country.name);
        },
      ),
    );
  }
}
