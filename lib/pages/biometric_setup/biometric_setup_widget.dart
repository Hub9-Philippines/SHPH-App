import 'package:flutter/material.dart';

import '/components/cupertino_ui/app_activity_indicator.dart';
import '/components/cupertino_ui/app_button.dart';
import '/components/cupertino_ui/app_text_field.dart';
import '/components/cupertino_ui/cupertino_page_header.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'biometric_setup_model.dart';

export 'biometric_setup_model.dart';

class BiometricSetupWidget extends StatefulWidget {
  const BiometricSetupWidget({super.key});

  static String routeName = 'BiometricSetup';
  static String routePath = '/biometric-setup';

  @override
  State<BiometricSetupWidget> createState() => _BiometricSetupWidgetState();
}

class _BiometricSetupWidgetState extends State<BiometricSetupWidget> {
  late BiometricSetupModel _model;
  final _deviceNameCtrl = TextEditingController();
  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, BiometricSetupModel.new);
    _model.loadCredentials().then((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _deviceNameCtrl.dispose();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: CupertinoPageHeader(
          backgroundColor: theme.primaryBackground,
          title: _l10n.bioSetupTitle,
          titleStyle: theme.titleMedium,
        ),
      ),
      body: _model.isLoading
          ? const Center(child: AppActivityIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info,
                          color: theme.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _l10n.bioSetupSubtitle,
                          style: theme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: theme.border, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_l10n.bioSetupRegister,
                          style: theme.titleSmall),
                      const SizedBox(height: 8),
                      AppTextField(
                        controller: _deviceNameCtrl,
                        placeholder: _l10n.bioSetupDeviceNameLabel,
                        radius: 8,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          onPressed: _model.isRegistering
                              ? null
                              : () async {
                                  final name = _deviceNameCtrl.text
                                          .trim()
                                          .isEmpty
                                      ? _l10n.bioSetupDeviceNameDefault
                                      : _deviceNameCtrl.text.trim();
                                  final ok = await _model
                                      .registerDevice(name);
                                  if (mounted) {
                                    if (ok) {
                                      await _model.loadCredentials();
                                      _deviceNameCtrl.clear();
                                      safeSetState(() {});
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              _l10n.bioSetupRegistered),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              _l10n.bioSetupRegistrationFailed),
                                        ),
                                      );
                                    }
                                  }
                                },
                          backgroundColor: theme.primary,
                          loading: _model.isRegistering,
                          child: Text(_l10n.bioSetupRegister),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_model.credentials.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(_l10n.bioSetupRegisteredDevices,
                      style: theme.titleSmall),
                  const SizedBox(height: 8),
                  ..._model.credentials.map((cred) {
                    final deviceName =
                        cred['device_name']?.toString() ?? _l10n.bioSetupUnknown;
                    final createdAt =
                        cred['created_at']?.toString() ?? '';
                    final pk = cred['id'] as int? ?? 0;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: theme.secondaryBackground,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: theme.border, width: 0.5),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.success
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.fingerprint,
                              color: theme.success),
                        ),
                        title: Text(deviceName,
                            style: theme.bodyMedium),
                        subtitle: createdAt.isNotEmpty
                            ? Text(createdAt,
                                style: theme.bodySmall)
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.delete,
                              color: theme.error, size: 20),
                          onPressed: () {
                            _model.deleteCredential(pk);
                            safeSetState(() {});
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
