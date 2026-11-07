import 'package:flutter/material.dart';

/// Input teks autentikasi yang mengikuti `inputDecorationTheme` global.
///
/// Halaman tidak lagi mendefinisikan border, fill, atau error border sendiri.
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.enabled = true,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final bool obscureText;
  final int? minLines;
  final int maxLines;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEmail = keyboardType == TextInputType.emailAddress;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      enabled: enabled,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      autofocus: autofocus,
      autocorrect: !isEmail,
      enableSuggestions: !isEmail,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        helperMaxLines: 3,
        errorMaxLines: 2,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

/// Field password dengan toggle tampil/sembunyi yang konsisten.
class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint,
    this.helperText,
    this.validator,
    this.textInputAction,
    this.autofillHints = const [AutofillHints.password],
    this.onFieldSubmitted,
    this.enabled = true,
    this.showVisibilityToggle = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? helperText;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final Iterable<String> autofillHints;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final bool showVisibilityToggle;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return AuthTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      helperText: widget.helperText,
      prefixIcon: Icons.lock_outline_rounded,
      suffixIcon: widget.showVisibilityToggle
          ? IconButton(
              tooltip: _obscure ? 'Tampilkan password' : 'Sembunyikan password',
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            )
          : null,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      obscureText: _obscure,
    );
  }
}
