import 'package:flutter/material.dart';
import 'package:viora/core/constants/app_theme.dart';
import 'package:viora/core/constants/theme_extensions.dart';

class LoginTextFormField extends StatefulWidget {
  final String label;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const LoginTextFormField({
    super.key,
    required this.label,
    this.validator,
    this.isPassword = false,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<LoginTextFormField> createState() => _LoginTextFormFieldState();
}

class _LoginTextFormFieldState extends State<LoginTextFormField> {
  bool _isFocused = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused ? AppTheme.metallicGold : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? AppTheme.metallicGold.withOpacity(0.2)
                  : Colors.transparent,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          style: theme.futuristicBody,
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: theme.futuristicBody.copyWith(
              color: _isFocused ? AppTheme.metallicGold : Colors.grey,
            ),
            filled: true,
            fillColor: theme.primarySurface.withOpacity(0.8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: _isFocused ? AppTheme.metallicGold : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
