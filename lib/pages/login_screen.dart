import 'package:chatty/commponents/my_textfiels.dart';
import 'package:chatty/pages/register_page.dart';
import 'package:chatty/services/auth/auth_services.dart'
    show AuthFirebase, AuthServices;
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key, this.onTap});

  final void Function()? onTap;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  void login() async {
    final authServices = AuthServices();

    try {
      await authServices.signInWithEmailAndPossword(
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
              hinText: 'passsword',
              controller: passwordController,
              obscureText: true,
            ),
            MaterialButton(onPressed: login, child: Text('Вход')),
            InkWell(onTap: widget.onTap, child: Text('To register')),
          ],
        ),
      ),
    );
  }
}
