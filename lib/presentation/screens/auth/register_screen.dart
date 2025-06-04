import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/screens/auth/login_screen.dart';
import 'package:viora/presentation/widgets/login_text_form_field.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/core/providers/user_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.registerNameRequired;
    }
    if (value.length < 3) {
      return AppLocalizations.of(context)!.registerNameLength;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.registerEmailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppLocalizations.of(context)!.registerEmailInvalid;
    }
    return null;
  }

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

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final success = await userProvider.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (success && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.registerError,
                style: Theme.of(context).futuristicBody,
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
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
    _nameController.dispose();
    _emailController.dispose();
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
                        localizations.registerTitle,
                        style: theme.futuristicTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Name Field
                      LoginTextFormField(
                        label: localizations.registerNameLabel,
                        controller: _nameController,
                        validator: _validateName,
                      ),
                      const SizedBox(height: 24),
                      // Email Field
                      LoginTextFormField(
                        label: localizations.registerEmailLabel,
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
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
                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
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
                                  localizations.registerButton,
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
                          localizations.registerLoginButton,
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
