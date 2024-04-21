import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeRouteButton extends StatelessWidget {
  final String? texto;
  final String route;

  const HomeRouteButton({
    Key? key,
    required this.texto,
    required this.route,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        /*  Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const RegistroScreen(),
          ),
        ); */
      },
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary, // Use primary color
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              texto!,
              style: const TextStyle(
                  color: Colors.black), // Set text color to black
            ),
          ),
        ),
      ),
    );
  }
}
