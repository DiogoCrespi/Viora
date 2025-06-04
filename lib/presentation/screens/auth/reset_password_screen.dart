import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/widgets/login_text_form_field.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/core/providers/user_provider.dart';
import 'package:viora/presentation/screens/auth/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.registerPasswordRequired;
    }
    if (value.length < 6) {
      return AppLocalizations.of(context)!.registerPasswordLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.registerConfirmPasswordRequired;
    }
    if (value != _passwordController.text) {
      return AppLocalizations.of(context)!.registerPasswordsDontMatch;
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final success = await userProvider.resetPassword(
          widget.email,
          _passwordController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? AppLocalizations.of(context)!.resetPasswordSuccess
                    : AppLocalizations.of(context)!.resetPasswordSamePassword,
                style: Theme.of(context).futuristicBody,
              ),
              backgroundColor: success ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );

          if (success) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: theme.gradientDecoration,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Icon(
                        Icons.rocket_launch,
                        size: 80,
                        color: theme.sunsetOrange,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        localizations.resetPasswordTitle,
                        style: theme.futuristicTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.resetPasswordDescription,
                        style: theme.futuristicBody,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Password Field
                      LoginTextFormField(
                        label: localizations.registerPasswordLabel,
                        controller: _passwordController,
                        validator: _validatePassword,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      // Confirm Password Field
                      LoginTextFormField(
                        label: localizations.registerConfirmPasswordLabel,
                        controller: _confirmPasswordController,
                        validator: _validateConfirmPassword,
                        isPassword: true,
                      ),
                      const SizedBox(height: 32),
                      // Reset Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleResetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.sunsetOrange,
                            foregroundColor: theme.primaryText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  localizations.resetPasswordButton,
                                  style: theme.futuristicSubtitle,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Back to Login Button
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        child: Text(
                          localizations.forgotPasswordBackButton,
                          style: theme.futuristicBody.copyWith(
                            color: theme.sunsetOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
