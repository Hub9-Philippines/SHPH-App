import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'back_button_model.dart';

export 'back_button_model.dart';

class BackButtonWidget extends StatefulWidget {
  const BackButtonWidget({super.key});

  @override
  State<BackButtonWidget> createState() => _BackButtonWidgetState();
}

class _BackButtonWidgetState extends State<BackButtonWidget> {
  late BackButtonModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BackButtonModel.new);
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FlutterFlowIconButton(
        borderRadius: 30,
        buttonSize: 60,
        hoverColor: const Color(0xFFD6D6D6),
        hoverBorderColor: AppTheme.of(context).primaryText,
        icon: const Icon(
          Icons.chevron_left_rounded,
          color: Color(0xFF525252),
          size: 30,
        ),
        onPressed: () async {
          if (context.canPop()) {
            context.pop();
          } else {
            // Fallback to home if there's no route to pop to
            context.goNamed('Home');
          }
        },
      );
}
