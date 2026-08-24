import 'package:flutter/material.dart';

class AppDialogs {
  static Future<void> showResetPasswordDialog({
    required BuildContext context,
    required void Function(String email) onSubmit,
  }) async {
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () {
                final email = controller.text.trim();
                if (email.isNotEmpty && email.contains('@')) {
                  Navigator.of(dialogContext).pop();
                  onSubmit(email);
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid email address.'),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }
}
