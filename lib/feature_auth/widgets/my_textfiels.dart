import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  MyTextField({
    super.key,
    required this.hinText,
    required this.controller,
    required this.obscureText,
    this.focusode,
  });
  final String hinText;
  final TextEditingController controller;
  final bool obscureText;
  final FocusNode? focusode;
  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusode,
      obscureText: obscureText,
      controller: controller,
      decoration: InputDecoration(hintText: hinText),
    );
  }
}
