import 'package:flutter/material.dart';

class HomeRouteButton extends StatelessWidget {
  final String? texto;
  final Widget routeComponent;

  const HomeRouteButton({
    super.key,
    required this.texto,
    required this.routeComponent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => routeComponent,
          ),
        );
      },
      child: SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              texto!,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
