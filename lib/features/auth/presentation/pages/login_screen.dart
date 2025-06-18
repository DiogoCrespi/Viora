import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/features/auth/presentation/widgets/login_text_form_field_widget.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/features/user/presentation/providers/user_provider.dart';
// import 'package:viora/core/config/supabase_config.dart'; // No longer directly used
import 'package:viora/routes.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.loginEmailRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppLocalizations.of(context)!.loginEmailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.loginPasswordRequired;
    }
    if (value.length < 6) {
      return AppLocalizations.of(context)!.loginPasswordLength;
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (kDebugMode) {
          debugPrint(
              'LoginScreen: Attempting login with email: ${_emailController.text}');
        }
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        // UserProvider.login should ideally return a more structured response or throw specific exceptions.
        // For this refactor, we'll assume it returns true on success (and session is guaranteed by provider),
        // or throws specific exceptions.
        await userProvider.login(
          _emailController.text,
          _passwordController.text,
        );

        // If login is successful, UserProvider should have updated its internal state
        // and potentially the global app state if a session is now active.
        // The navigation should occur if mounted.
        if (mounted) {
          if (kDebugMode) {
            debugPrint('LoginScreen: Login successful, navigating to main.');
          }
          context.pushNamedAndRemoveUntil(AppRoutes.main);
        }
      } catch (e) { // Catching generic Exception, but conceptually UserProvider would throw specific ones.
        if (kDebugMode) {
          debugPrint('LoginScreen: Error during login: $e');
        }
        if (!mounted) return;

        final localizations = AppLocalizations.of(context)!;
        String message = localizations.loginError; // Default error message
        bool showResendAction = false;

        // Conceptual: In a real scenario, UserProvider would throw typed exceptions.
        // For now, we simulate this by checking the error message as before,
        // but ideally, this logic moves to UserProvider or is replaced by typed exceptions.
        final errorMessageString = e.toString().toLowerCase();

        if (errorMessageString.contains('invalid credentials') || // Common Supabase error
            errorMessageString.contains('invalid_grant')) { // From GoTrueException
          message = localizations.loginError; // Specific message for invalid credentials
        } else if (errorMessageString.contains('email not confirmed') ||
                   errorMessageString.contains('email_not_confirmed') || // From GoTrueException
                   errorMessageString.contains('registererroremailconfirmationrequired')) {
          message = localizations.loginErrorEmailNotConfirmed;
          showResendAction = true;
        } else if (errorMessageString.contains('network request failed') || // Common network error
                   errorMessageString.contains('no internet connection')) {
          message = localizations.loginErrorNoConnection;
        } else if (errorMessageString.contains('server unavailable')) {
          message = localizations.loginErrorServerUnavailable;
        }
        // Add more specific error checks if UserProvider starts throwing them

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: Theme.of(context).futuristicBody),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            duration: const Duration(seconds: 5),
            action: showResendAction
                ? SnackBarAction(
                    label: localizations.loginResendConfirmation,
                    textColor: Colors.white,
                    onPressed: () async {
                      if (!mounted) return;
                      final String email = _emailController.text;
                      try {
                        final userProvider = Provider.of<UserProvider>(context, listen: false);
                        await userProvider.resendConfirmationEmail(email);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.loginConfirmationEmailSent, style: Theme.of(context).futuristicBody),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          );
                        }
                      } catch (resendError) {
                        if (!mounted) return;
                         String resendMessage = localizations.loginErrorResendingConfirmation;
                         if (resendError.toString().toLowerCase().contains('over_email_send_rate_limit')) {
                           resendMessage = localizations.loginErrorRateLimit; // Assuming you add this to ARB
                         }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(resendMessage, style: Theme.of(context).futuristicBody),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        );
                      }
                    },
                  )
                : null,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _navigateToRegister() {
    context.pushNamed(AppRoutes.register);
  }

  void _navigateToForgotPassword() {
    context.pushNamed(AppRoutes.forgotPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                        localizations.loginTitle,
                        style: theme.futuristicTitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      // Email Field
                      LoginTextFormField(
                        label: localizations.loginEmailLabel,
                        controller: _emailController,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      // Password Field
                      LoginTextFormField(
                        label: localizations.loginPasswordLabel,
                        controller: _passwordController,
                        validator: _validatePassword,
                        isPassword: true,
                      ),
                      const SizedBox(height: 32),
                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
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
                                  localizations.loginButton,
                                  style: theme.futuristicSubtitle,
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Register Button
                      TextButton(
                        onPressed: _navigateToRegister,
                        child: Text(
                          localizations.loginRegisterButton,
                          style: theme.futuristicBody.copyWith(
                            color: theme.sunsetOrange,
                          ),
                        ),
                      ),
                      // Forgot Password Button
                      TextButton(
                        onPressed: _navigateToForgotPassword,
                        child: Text(
                          localizations.loginForgotPasswordButton,
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
