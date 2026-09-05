import 'package:flutter/material.dart';

void showSettingsSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
}) {
  final colors = Theme.of(context).colorScheme;
  final backgroundColor = isError ? colors.error : colors.inverseSurface;
  final foregroundColor = isError ? colors.onError : colors.onInverseSurface;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline,
              color: foregroundColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
