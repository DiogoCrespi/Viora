import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/core/providers/theme_provider.dart';
import 'package:viora/core/providers/font_size_provider.dart';
import 'package:viora/core/providers/locale_provider.dart'; // Added
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Added

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  // String _selectedLanguage = 'Português'; // Removed

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context); // Added

    // Define language map for Dropdown
    final Map<String, String> languages = {
      'en': AppLocalizations.of(context)!.languageEnglish,
      'pt': AppLocalizations.of(context)!.languagePortuguese,
      // 'es': AppLocalizations.of(context)!.languageSpanish, // Assuming Spanish might be added later
    };

    return Container(
      decoration: theme.gradientDecoration,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.settings_outlined,
                    size: 32,
                    color: theme.sunsetOrange,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.settingsTitle, // Localized
                    style: theme.futuristicTitle,
                  ),
                ],
              ),
            ),

            // Lista de Configurações
            Expanded(
              child: ListView(
                children: [
                  _buildSection(context, AppLocalizations.of(context)!.generalPreferencesTitle, [ // Localized
                    _buildSwitchTile(
                      AppLocalizations.of(context)!.notificationsSettingTitle, // Localized
                      AppLocalizations.of(context)!.notificationsSettingSubtitle, // Localized
                      Icons.notifications_outlined,
                      _notificationsEnabled,
                      (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      AppLocalizations.of(context)!.darkModeSettingTitle, // Localized
                      AppLocalizations.of(context)!.darkModeSettingSubtitle, // Localized
                      Icons.dark_mode_outlined,
                      themeProvider.isDarkMode,
                      (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, AppLocalizations.of(context)!.accessibilityTitle, [ // Localized
                    _buildSliderTile(
                      AppLocalizations.of(context)!.fontSizeSettingTitle, // Localized
                      AppLocalizations.of(context)!.fontSizeSettingSubtitle, // Localized
                      Icons.format_size_outlined,
                      fontSizeProvider.fontSize,
                      (value) {
                        fontSizeProvider.setFontSize(value);
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, AppLocalizations.of(context)!.languageSettingTitle, [ // Localized
                    _buildDropdownTile(
                        context,
                        AppLocalizations.of(context)!.languageSettingTitle, // Localized
                        AppLocalizations.of(context)!.languageSettingSubtitle, // Localized
                        Icons.language_outlined,
                        localeProvider.locale?.languageCode ??
                            'en',
                        languages, (String? newLanguageCode) {
                      if (newLanguageCode != null) {
                        Provider.of<LocaleProvider>(context, listen: false)
                            .setLocale(Locale(newLanguageCode));
                      }
                    }),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, AppLocalizations.of(context)!.accountTitle, [ // Localized
                    _buildActionTile(
                      AppLocalizations.of(context)!.profileSettingTitle, // Localized
                      AppLocalizations.of(context)!.profileSettingSubtitle, // Localized
                      Icons.person_outline,
                      () {
                        // TODO: Implementar navegação para perfil
                      },
                    ),
                    _buildActionTile(
                      AppLocalizations.of(context)!.privacySettingTitle, // Localized
                      AppLocalizations.of(context)!.privacySettingSubtitle, // Localized
                      Icons.privacy_tip_outlined,
                      () {
                        // TODO: Implementar navegação para privacidade
                      },
                    ),
                    _buildActionTile(
                      AppLocalizations.of(context)!.logoutSettingTitle, // Localized
                      AppLocalizations.of(context)!.logoutSettingSubtitle, // Localized
                      Icons.logout_outlined,
                      () {
                        // TODO: Implementar logout
                      },
                      isDestructive: true,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: theme.futuristicSubtitle,
          ),
        ),
        Card(
          color: theme.primarySurface.withOpacity(0.95),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.sunsetOrange.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.sunsetOrange),
      title: Text(
        title,
        style: theme.futuristicSubtitle,
      ),
      subtitle: Text(
        subtitle,
        style: theme.futuristicBody,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: theme.sunsetOrange,
        activeTrackColor: theme.primaryText.withOpacity(0.5),
      ),
    );
  }

  Widget _buildDropdownTile(
    BuildContext context, // Added context
    String title,
    String subtitle,
    IconData icon,
    String currentValue,
    Map<String, String> languageMap, // Changed from List<String> to Map
    ValueChanged<String?> onChanged,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.sunsetOrange),
      title: Text(
        title, // This will be localized
        style: theme.futuristicSubtitle,
      ),
      subtitle: Text(
        subtitle, // This will be localized
        style: theme.futuristicBody,
      ),
      trailing: DropdownButton<String>(
        value: currentValue,
        items: languageMap.entries.map((MapEntry<String, String> entry) {
          return DropdownMenuItem<String>(
            value: entry.key, // language code
            child: Text(entry.value, style: theme.futuristicBody), // language name
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(height: 2, color: theme.sunsetOrange),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    final theme = Theme.of(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return ListTile(
      leading: Icon(icon, color: theme.sunsetOrange),
      title: Text(
        title,
        style: theme.futuristicSubtitle,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: theme.futuristicBody,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A-',
                style: theme.futuristicBody.copyWith(
                  fontSize: 14 * fontSizeProvider.fontSize,
                ),
              ),
              Text(
                'A+',
                style: theme.futuristicBody.copyWith(
                  fontSize: 18 * fontSizeProvider.fontSize,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: theme.sunsetOrange,
            inactiveColor: theme.primaryText.withOpacity(0.3),
            min: 0.8,
            max: 1.2,
            divisions: 4,
            label: '${(value * 100).round()}%',
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : theme.sunsetOrange,
      ),
      title: Text(
        title,
        style: theme.futuristicSubtitle.copyWith(
          color: isDestructive
              ? Colors.red
              : (theme.brightness == Brightness.light
                  ? Colors.black
                  : Colors.white),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.futuristicBody.copyWith(
          color: isDestructive
              ? Colors.red.withOpacity(0.7)
              : (theme.brightness == Brightness.light
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.7)),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red : theme.sunsetOrange,
      ),
      onTap: onTap,
    );
  }
}
