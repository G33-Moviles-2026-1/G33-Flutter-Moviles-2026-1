import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String hintText;
  final String? Function(String?)? validator;

  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.obscureText,
    required this.onToggleVisibility,
    required this.hintText,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final visibilityIcon =
        obscureText ? Icons.visibility_off : Icons.visibility;

    return TextFormField(
      controller: controller,
      inputFormatters: [
        LengthLimitingTextInputFormatter(20),
      ],
      focusNode: focusNode,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: focusNode.hasFocus
            ? IconButton(
                icon: Icon(visibilityIcon),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
      validator: validator,
    );
  }
}