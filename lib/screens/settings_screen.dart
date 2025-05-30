import 'package:flutter/material.dart';
import 'package:viora/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Português';
  double _fontSize = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.deepBrown, AppTheme.geometricBlack],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
                    color: AppTheme.metallicGold,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Configurações',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.metallicGold,
                      fontWeight: FontWeight.bold,
                    ),
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
                      _darkModeEnabled,
                      (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSection(context, 'Personalização', [
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
                    _buildSliderTile(
                      'Tamanho da Fonte',
                      'Ajuste o tamanho do texto',
                      Icons.format_size_outlined,
                      _fontSize,
                      (value) {
                        setState(() {
                          _fontSize = value;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.metallicGold,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          color: AppTheme.agedBeige.withOpacity(0.95),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppTheme.metallicGold.withOpacity(0.5),
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
    return ListTile(
      leading: Icon(icon, color: AppTheme.metallicGold),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.deepBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTheme.deepBrown.withOpacity(0.7)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.metallicGold,
        activeTrackColor: AppTheme.deepBrown.withOpacity(0.5),
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
    return ListTile(
      leading: Icon(icon, color: AppTheme.metallicGold),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.deepBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTheme.deepBrown.withOpacity(0.7)),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        underline: Container(height: 2, color: AppTheme.metallicGold),
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
    return ListTile(
      leading: Icon(icon, color: AppTheme.metallicGold),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.deepBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: TextStyle(color: AppTheme.deepBrown.withOpacity(0.7)),
          ),
          Slider(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.metallicGold,
            inactiveColor: AppTheme.deepBrown.withOpacity(0.3),
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
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppTheme.metallicGold,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppTheme.deepBrown,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color:
              isDestructive
                  ? Colors.red.withOpacity(0.7)
                  : AppTheme.deepBrown.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDestructive ? Colors.red : AppTheme.metallicGold,
      ),
      onTap: onTap,
    );
  }
}
