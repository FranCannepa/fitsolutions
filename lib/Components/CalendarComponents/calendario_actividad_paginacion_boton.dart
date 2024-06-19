import 'package:flutter/material.dart';

class PaginationButton extends StatelessWidget {
  final String direccion;
  final VoidCallback onPressed;

  const PaginationButton({
    super.key,
    required this.direccion,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;

    switch (direccion) {
      case 'next':
        iconData = Icons.arrow_forward_ios;
        break;
      case 'before':
        iconData = Icons.arrow_back_ios;
        break;
      default:
        throw ArgumentError('Invalid direction: $direccion');
    }

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(0.2), // Semi-transparent background
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Ensures compact size
          children: [
            Text(direccion),
            const SizedBox(width: 4.0),
            Icon(iconData),
          ],
        ),
      ),
    );
  }
}
