import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  const UserTile({super.key, this.onTap, required this.text});

  final void Function()? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.046,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
