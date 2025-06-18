import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/features/auth/presentation/widgets/login_text_form_field_widget.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/features/user/presentation/providers/user_provider.dart';
import 'package:viora/routes.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).futuristicBody,
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        if (mounted) {
          // Potentially show a success message before navigating,
          // or navigate and let the login screen show a "please check your email" message
          // if email confirmation is required and UserProvider.register now signals this.
          // For now, direct navigation on success (no exception).
          if (kDebugMode) {
            debugPrint(
                'RegisterScreen: Registration successful, navigating to login.');
          }
          context.pushReplacementNamed(AppRoutes.login);
        }
      } catch (e) {
        // Conceptual: Catch specific exceptions like EmailInUseException, WeakPasswordException etc.
        if (!mounted) return;

        final localizations = AppLocalizations.of(context)!;
        String message = localizations.registerError; // Default error
        final errorMessageString = e.toString().toLowerCase();

        if (kDebugMode) {
          debugPrint('RegisterScreen: Registration error: $e');
        }

        // This mapping would be simplified if UserProvider threw typed exceptions
        if (errorMessageString
                .contains('email_already_in_use') || // Supabase specific
            errorMessageString.contains('registererroremailinuse')) {
          // Current custom
          message = localizations.registerErrorEmailInUse;
        } else if (errorMessageString.contains('weak password')) {
          // Supabase specific
          message = localizations
              .registerErrorInvalidData; // Usando mensagem de erro genérica para senha fraca
        } else if (errorMessageString.contains('network request failed')) {
          message = localizations.registerErrorNoConnection;
        } else if (errorMessageString.contains('server unavailable')) {
          message = localizations.registerErrorServerUnavailable;
        } else if (errorMessageString.contains('invalid data') ||
            errorMessageString.contains('registererrorinvaliddata')) {
          message = localizations.registerErrorInvalidData;
        } else if (errorMessageString.contains('email confirmation required') ||
            errorMessageString
                .contains('registererroremailconfirmationrequired')) {
          // UserProvider.register might handle this by not throwing an error but returning a specific success state,
          // or by throwing a specific EmailConfirmationRequiredException.
          // For now, if UserProvider throws for this, we show the message.
          message = localizations.registerErrorEmailConfirmationRequired;
        } else if (errorMessageString
                .contains('invalid email') || // Supabase specific for format
            errorMessageString.contains('registererrorinvalidemail')) {
          message = localizations.registerErrorInvalidEmail;
        }

        _showErrorSnackBar(message);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _navigateToLogin() {
    context.pushNamed(AppRoutes.login);
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
                        onPressed: _navigateToLogin,
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
