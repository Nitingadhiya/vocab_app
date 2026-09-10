import 'package:flutter/material.dart';
import 'package:vocab_app/core/theme/app_css.dart';
import 'package:vocab_app/core/theme/scale.dart';
import 'package:vocab_app/core/utils/textstyle_extensions.dart';

Future<void> showAlertDialog({required BuildContext context, String? title, required String body}) {
  final colorScheme = Theme.of(context).colorScheme;
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r16)),
      title: title != null ? Text(title, style: AppCss.bodyBaseSemibold) : null,
      content: Text(body, style: AppCss.bodySmall),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK', style: AppCss.bodySmallSemiBold.textColor(colorScheme.primary)),
        ),
      ],
    ),
  );
}
