import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/core/providers/theme_provider.dart';
import 'package:viora/core/providers/font_size_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Português';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

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
                    'Configurações',
                    style: theme.futuristicTitle,
                  ),
                ],
              ),
            ),

            // Lista de Configurações
            Expanded(
              child: ListView(
                children: [
                  _buildSection(context, 'Preferências Gerais', [
                    _buildSwitchTile(
                      'Notificações',
                      'Receber alertas e atualizações',
                      Icons.notifications_outlined,
                      _notificationsEnabled,
                      (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildSwitchTile(
                      'Modo Escuro',
                      'Alternar entre tema claro e escuro',
                      Icons.dark_mode_outlined,
                      themeProvider.isDarkMode,
                      (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Acessibilidade', [
                    _buildSliderTile(
                      'Tamanho da Fonte',
                      'Ajuste o tamanho do texto',
                      Icons.format_size_outlined,
                      fontSizeProvider.fontSize,
                      (value) {
                        fontSizeProvider.setFontSize(value);
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Idioma', [
                    _buildDropdownTile(
                      'Idioma',
                      'Selecione o idioma do aplicativo',
                      Icons.language_outlined,
                      _selectedLanguage,
                      ['Português', 'English', 'Español'],
                      (value) {
                        setState(() {
                          _selectedLanguage = value!;
                        });
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Conta', [
                    _buildActionTile(
                      'Perfil',
                      'Gerencie suas informações pessoais',
                      Icons.person_outline,
                      () {
                        // TODO: Implementar navegação para perfil
                      },
                    ),
                    _buildActionTile(
                      'Privacidade',
                      'Configure suas preferências de privacidade',
                      Icons.privacy_tip_outlined,
                      () {
                        // TODO: Implementar navegação para privacidade
                      },
                    ),
                    _buildActionTile(
                      'Sair',
                      'Encerrar sessão na sua conta',
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
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
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
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: theme.futuristicBody),
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
