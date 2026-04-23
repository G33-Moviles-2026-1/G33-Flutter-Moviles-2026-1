import 'package:flutter/material.dart';

class AuthFooterLink extends StatelessWidget {
  final String prefixText;
  final String actionText;
  final VoidCallback onPressed;

  const AuthFooterLink({
    super.key,
    required this.prefixText,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prefixText,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionText,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}