import 'package:chatty/services/auth/auth_services.dart';
import 'package:chatty/commponents/my_textfiels.dart';
import 'package:chatty/pages/login_screen.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key, this.onTap});

  final void Function()? onTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController passwordControllerConfirm = TextEditingController();

  void register() async {
    final auth = AuthServices();

    if (passwordController.text == passwordControllerConfirm.text) {
      try {
        auth.signUpWithEmailAndPossword(
          emailController.text,
          passwordController.text,
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              hinText: 'passsword ',
              controller: passwordController,
              obscureText: true,
            ),
            MyTextField(
              hinText: 'passsword Confirm',
              controller: passwordControllerConfirm,
              obscureText: true,
            ),
            MaterialButton(onPressed: register, child: Text('Регистрация')),
            InkWell(onTap: widget.onTap, child: Text('To register')),
          ],
        ),
      ),
    );
  }
}
