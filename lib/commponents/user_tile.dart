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
          Container(
            height: 40,
            width: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.person), Text(text)],
            ),
          ),
        ],
      ),
    );
  }
}
