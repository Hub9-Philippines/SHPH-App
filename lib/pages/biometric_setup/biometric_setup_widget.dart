import 'package:flutter/material.dart';

import '/flutter_flow/flutter_flow_util.dart';
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
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        title: Text('Biometric Setup', style: theme.titleMedium),
        centerTitle: true,
        elevation: 0,
      ),
      body: _model.isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          'Use your fingerprint or face to sign in quickly and securely.',
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
                      Text('Register this device',
                          style: theme.titleSmall),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _deviceNameCtrl,
                        decoration: InputDecoration(
                          hintText: 'Device name (e.g. My Phone)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _model.isRegistering
                              ? null
                              : () async {
                                  final name = _deviceNameCtrl.text
                                          .trim()
                                          .isEmpty
                                      ? 'My Device'
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
                                        const SnackBar(
                                          content: Text(
                                              'Device registered'),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Registration failed'),
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                          ),
                          child: _model.isRegistering
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white),
                                )
                              : const Text(
                                  'Register this device'),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_model.credentials.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Registered Devices',
                      style: theme.titleSmall),
                  const SizedBox(height: 8),
                  ..._model.credentials.map((cred) {
                    final deviceName =
                        cred['device_name']?.toString() ?? 'Unknown';
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
