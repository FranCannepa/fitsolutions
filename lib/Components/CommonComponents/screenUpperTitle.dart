import 'package:flutter/material.dart';

class ScreenUpperTitle extends StatelessWidget {
  final String title;

  const ScreenUpperTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 30, top: 30),
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 30.0),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'TitleFont'),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
  }
}
