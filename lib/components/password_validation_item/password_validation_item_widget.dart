import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import 'password_validation_item_model.dart';

export 'password_validation_item_model.dart';

class PasswordValidationItemWidget extends StatefulWidget {
  const PasswordValidationItemWidget({
    required this.label, super.key,
    bool? isValid,
  }) : this.isValid = isValid ?? false;

  final bool isValid;
  final String? label;

  @override
  State<PasswordValidationItemWidget> createState() =>
      _PasswordValidationItemWidgetState();
}

class _PasswordValidationItemWidgetState
    extends State<PasswordValidationItemWidget> {
  late PasswordValidationItemModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, PasswordValidationItemModel.new);
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Builder(
            builder: (context) {
              if (widget.isValid) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/CheckCircle.png',
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/XCircle.png',
                    width: 16,
                    height: 16,
                    fit: BoxFit.cover,
                  ),
                );
              }
            },
          ),
          Expanded(
            child: AnimatedDefaultTextStyle(
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight:
                          AppTheme.of(context).bodySmall.fontWeight,
                      fontStyle:
                          AppTheme.of(context).bodySmall.fontStyle,
                    ),
                    color: widget.isValid
                        ? AppTheme.of(context).success
                        : AppTheme.of(context).error,
                    letterSpacing: 0,
                    fontWeight:
                        AppTheme.of(context).bodySmall.fontWeight,
                    fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                  ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Text(
                valueOrDefault<String>(
                  widget.label,
                  'No label',
                ),
              ),
            ),
          ),
        ].divide(const SizedBox(width: 8)),
      ),
    );
}
