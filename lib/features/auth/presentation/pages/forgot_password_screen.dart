import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/features/auth/presentation/widgets/login_text_form_field.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/features/user/presentation/providers/user_provider.dart';
import 'package:viora/features/auth/presentation/pages/reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.forgotPasswordEmailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppLocalizations.of(context)!.forgotPasswordEmailInvalid;
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
        final success =
            await userProvider.requestPasswordReset(_emailController.text);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? AppLocalizations.of(context)!.forgotPasswordSuccess
                    : AppLocalizations.of(context)!.forgotPasswordError,
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(
                  email: _emailController.text,
                ),
              ),
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
    _emailController.dispose();
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
                        localizations.forgotPasswordTitle,
                        style: theme.futuristicTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        localizations.forgotPasswordDescription,
                        style: theme.futuristicBody,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Email Field
                      LoginTextFormField(
                        label: localizations.forgotPasswordEmailLabel,
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
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
                                  localizations.forgotPasswordButton,
                                  style: theme.futuristicSubtitle,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Back to Login Button
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
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
