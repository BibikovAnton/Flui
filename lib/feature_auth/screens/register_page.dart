import 'package:Flui/feature_auth/providers/register_provider.dart'
    show RegisterNotifier, registerProvider;
import 'package:Flui/feature_auth/widgets/my_textfiels.dart';

import 'package:flutter/material.dart';

import '../feature_auth.dart';

class RegisterPage extends ConsumerWidget {
  RegisterPage({super.key, this.onTap});

  final void Function()? onTap;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordControllerConfirm =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerProvider);
    final notifier = ref.read(registerProvider.notifier);

    // Показываем ошибки, если они есть
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, state.error!, notifier);
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Регистрация',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              MyTextField(
                hinText: 'Имя',
                controller: nameController,
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                hinText: 'Email',
                controller: emailController,
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                hinText: 'Пароль',
                controller: passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              MyTextField(
                hinText: 'Подтвердите пароль',
                controller: passwordControllerConfirm,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              state.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed:
                        () => notifier.register(
                          email: emailController.text,
                          password: passwordController.text,
                          name: nameController.text,
                          confirmPassword: passwordControllerConfirm.text,
                        ),
                    child: const Text('Зарегистрироваться'),
                  ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: onTap,
                child: const Text('Уже есть аккаунт? Войти'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String message,
    RegisterNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Ошибка'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  notifier.clearError();
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
