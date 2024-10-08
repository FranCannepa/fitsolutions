import 'package:fitsolutions/Components/CommonComponents/screen_sub_title.dart';
import 'package:fitsolutions/providers/user_data.dart';
import 'package:flutter/material.dart';

class MembresiaPicker extends StatelessWidget {
  final VoidCallback onClose;
  final UserData provider;
  const MembresiaPicker(
      {super.key, required this.onClose, required this.provider});

  @override
  Widget build(BuildContext context) {
    final userId = provider.getUserId() as String;
    return Dialog(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ScreenSubTitle(text: "Membresias Disponibles"),
            FutureBuilder(
              future: provider.getMembresias(userId),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final membresias = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: membresias.length,
                    itemBuilder: (context, index) {
                      final membresia = membresias[index];
                      return Text(membresia['nombreMembresia']);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text(
                      'Error fetching memberships: ${snapshot.error}'); 
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
