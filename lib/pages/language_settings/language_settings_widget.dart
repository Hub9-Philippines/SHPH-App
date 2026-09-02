import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/components/back_button/back_button_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/l10n/app_localizations.dart';
import '/theme/app_theme.dart';
import 'language_settings_model.dart';

export 'language_settings_model.dart';

class LanguageSettingsWidget extends StatefulWidget {
  const LanguageSettingsWidget({super.key});

  static String routeName = 'LanguageSettings';
  static String routePath = '/language-settings';

  @override
  State<LanguageSettingsWidget> createState() => _LanguageSettingsWidgetState();
}

class _LanguageSettingsWidgetState extends State<LanguageSettingsWidget> {
  late LanguageSettingsModel _model;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedLanguage = 'English';
  String _selectedLocale = 'en';

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'flag': 'EN'},
    {'code': 'fil', 'name': 'Filipino', 'flag': 'FIL'},
  ];

  @override
  void initState() {
    super.initState();
    _model = createModel(context, LanguageSettingsModel.new);
    _selectedLocale = FFAppState().locale;
    _selectedLanguage = _localeToName(_selectedLocale);
  }

  String _localeToName(String code) {
    for (final lang in _languages) {
      if (lang['code'] == code) return lang['name']!;
    }
    return 'English';
  }

  void _saveLanguage(String language) {
    String? newCode;
    for (final lang in _languages) {
      if (lang['name'] == language) {
        newCode = lang['code'];
        break;
      }
    }
    if (newCode == null) return;

    FFAppState().locale = newCode;
    if (!mounted) return;

    setState(() {
      _selectedLanguage = language;
      _selectedLocale = newCode!;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_l10n.lgChanged(language))),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: const Color(0xFFF4F7FB),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: wrapWithModel(
                          model: _model.backButtonModel,
                          updateCallback: () => safeSetState(() {}),
                          child: const BackButtonWidget(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _l10n.lgTitle,
                              style: AppTheme.of(context).titleLarge.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: const Color(0xFF14213D),
                                  ),
                            ),
                            Text(
                              _l10n.lgSubtitle,
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color: const Color(0xFF64748B),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F8A6C),
                              Color(0xFF17B890),
                              Color(0xFF73D8B4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x220F8A6C),
                              blurRadius: 24,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _l10n.lgCurrent,
                              style: AppTheme.of(context).bodySmall.override(
                                    font: GoogleFonts.plusJakartaSans(),
                                    color: Colors.white.withValues(alpha: 0.82),
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _selectedLanguage,
                              style: AppTheme.of(context).headlineSmall.override(
                                    font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    color: Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      ..._languages.map(
                        (language) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildLanguageOption(
                            language,
                            _selectedLanguage == language['name'],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildLanguageOption(
    Map<String, String> language,
    bool isSelected,
  ) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.of(context).primary
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        // ListTile paints ink on the nearest Material ancestor; a rounded
        // white Material here keeps the ripple visible above the card's
        // DecoratedBox background (framework assertion fix).
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: ListTile(
            onTap: () => _saveLanguage(language['name']!),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.of(context).primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  language['flag']!,
                  style: AppTheme.of(context).labelLarge.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                        ),
                        color: AppTheme.of(context).primary,
                      ),
                ),
              ),
            ),
            title: Text(
              language['name']!,
              style: AppTheme.of(context).titleMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                    ),
                    color: const Color(0xFF14213D),
                  ),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.of(context).primary,
                    size: 28,
                  )
                : const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
          ),
        ),
      );
}
