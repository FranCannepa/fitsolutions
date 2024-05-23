import 'package:fitsolutions/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await userProvider.resetPassword(_emailController.text);
                  if(context.mounted){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password reset email sent")),
                    );
                    Navigator.pop(context); // Return to login page
                  }

                } catch (e) {
                  if(context.mounted){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Error al enviar email de Reset")),
                    );
                  }
                }
              },
              child: const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
