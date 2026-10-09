import 'package:flutter/material.dart';

import '/pages/unified_auth/unified_auth_widget.dart';
import 'signin_model.dart';

export 'signin_model.dart';

class SigninWidget extends StatefulWidget {
  const SigninWidget({super.key, this.email});

  final String? email;

  static String routeName = 'Signin';
  static String routePath = '/signin';

  @override
  State<SigninWidget> createState() => _SigninWidgetState();
}

class _SigninWidgetState extends State<SigninWidget> {
  @override
  Widget build(BuildContext context) {
    return UnifiedAuthWidget(initialInput: widget.email);
  }
}
