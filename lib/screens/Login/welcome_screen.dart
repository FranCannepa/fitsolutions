import 'package:fitsolutions/Components/CommonComponents/image_logo.dart';
import 'package:fitsolutions/providers/user_provider.dart';
import 'package:fitsolutions/screens/Login/login_email_screen.dart';
import 'package:fitsolutions/screens/Login/register_email_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        body: SafeArea(
            top: true,
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 700,
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                  ),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                    child: Column(
                      children: [
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              LoginEmailScreen(userProvider: userProvider),
                              RegisterEmailScreen(userProvider: userProvider)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ))));
  }
}
