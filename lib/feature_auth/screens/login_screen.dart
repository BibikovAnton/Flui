import 'package:Flui/feature_auth/providers/login_provider.dart';
import 'package:Flui/feature_auth/widgets/my_textfiels.dart';
import 'package:flutter/material.dart';

import '../feature_auth.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key, this.onTap});

  final void Function()? onTap;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginProvider);
    final loginNotifier = ref.read(loginProvider.notifier);

    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, state.error!, loginNotifier);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyTextField(
              hinText: 'email',
              controller: emailController,
              obscureText: false,
            ),
            MyTextField(
              hinText: 'password',
              controller: passwordController,
              obscureText: true,
            ),
            state.isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed:
                      () => loginNotifier.login(
                        emailController.text,
                        passwordController.text,
                      ),
                  child: Text('Вход'),
                ),
            TextButton(onPressed: onTap, child: Text('To register')),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String error,
    LoginNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Ошибка'),
            content: Text(error),
            actions: [
              TextButton(
                onPressed: () {
                  notifier.clearError();
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
