import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viora/core/constants/theme_extensions.dart';
import 'package:viora/presentation/screens/main_screen.dart';
import 'package:viora/presentation/screens/auth/register_screen.dart';
import 'package:viora/presentation/screens/auth/forgot_password_screen.dart';
import 'package:viora/presentation/widgets/login_text_form_field.dart';
import 'package:viora/l10n/app_localizations.dart';
import 'package:viora/core/providers/user_provider.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        debugPrint(
            'LoginScreen: Attempting login with email: ${_emailController.text}');
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final success = await userProvider.login(
          _emailController.text,
          _passwordController.text,
        );

        if (success && mounted) {
          debugPrint('LoginScreen: Login successful, navigating to main');
          // Verifica se a sessão foi criada corretamente
          final session = SupabaseConfig.client.auth.currentSession;
          debugPrint(
              'LoginScreen: Current session after login: ${session?.user.id}');

          if (session != null) {
            Navigator.pushReplacementNamed(context, '/main');
          } else {
            debugPrint('LoginScreen: No session found after login');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.loginErrorNoSession,
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
          }
        }
      } catch (e) {
        debugPrint('LoginScreen: Error during login: $e');
        if (mounted) {
          final errorMessage = e.toString();
          final localizations = AppLocalizations.of(context)!;

          String message;
          if (errorMessage.contains('loginErrorEmailNotConfirmed')) {
            message = localizations.loginErrorEmailNotConfirmed;
          } else if (errorMessage.contains('registerErrorEmailConfirmationRequired')) {
            message = localizations.registerErrorEmailConfirmationRequired;
          } else {
            message = localizations.loginError;
          }

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
              action: errorMessage.contains('email_not_confirmed') || 
                     errorMessage.contains('loginErrorEmailNotConfirmed') ||
                     errorMessage.contains('registerErrorEmailConfirmationRequired')
                  ? SnackBarAction(
                      label: localizations.loginResendConfirmation,
                      textColor: Colors.white,
                      onPressed: () async {
                        try {
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          await userProvider.resendConfirmationEmail(_emailController.text);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.loginConfirmationEmailSent,
                                  style: Theme.of(context).futuristicBody,
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            String message = localizations.loginErrorResendingConfirmation;
                            if (e.toString().contains('over_email_send_rate_limit')) {
                              message = 'Por favor, aguarde 60 segundos antes de tentar novamente.';
                            }
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
                              ),
                            );
                          }
                        }
                      },
                    )
                  : null,
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

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
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
