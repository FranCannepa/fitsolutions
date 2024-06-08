import 'package:fitsolutions/components/CalendarComponents/calendarioDisplayer.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.topRight, // Align the button to the bottom right corner
            margin: const EdgeInsets.all(16), // Adjust margin as needed

            child: IconButton(
              onPressed: () async {
                UserProvider userProvider = context.read<UserProvider>();
                await userProvider.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const WelcomePage(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout),
            ),
          ),
          const CalendarioDisplayer(),
        ],
      ),
    );
  }
}
