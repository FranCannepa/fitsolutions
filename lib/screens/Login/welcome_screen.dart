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

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {

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
      backgroundColor: Colors.grey.shade400,
      body: SafeArea(
          top: true,
          child: Row(mainAxisSize: MainAxisSize.max, children: [
            Expanded(
                flex: 8,
                child: Container(
                    width: 100,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                    ),
                    alignment: const AlignmentDirectional(0, -1),
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 45, 0, 0),
                          child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(
                                maxWidth: 600,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(0),
                                ),
                              ),
                              alignment: const AlignmentDirectional(-1, 0),
                              child: const Align(
                                  alignment: AlignmentDirectional(-1, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            16, 0, 0, 0),
                                        child: Text(
                                          'FitSolutions',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: Color(0xFF101213),
                                            fontSize: 24,
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))),
                        ),
                        Container(
                          width: double.infinity,
                          height: 700,
                          constraints: const BoxConstraints(
                            maxWidth: 600,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                          ),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            child: Column(
                              children: [
                                Align(
                                  child: TabBar(
                                    controller: _tabController,
                                    isScrollable: true,
                                    labelColor: const Color(0xFF101213),
                                    unselectedLabelColor:
                                        const Color(0xFF57636C),
                                    labelPadding: const EdgeInsets.all(16),
                                    labelStyle: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Color(0xFF101213),
                                      fontSize: 36,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    unselectedLabelStyle: const TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: Color(0xFF101213),
                                      fontSize: 36,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    indicatorColor: const Color(0xFF4B39EF),
                                    indicatorWeight: 4,
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            0, 12, 16, 12),
                                    tabs: const [
                                      Tab(
                                        text: 'Iniciar sesion',
                                      ),
                                      Tab(
                                        text: 'Registrar',
                                      ),
                                    ],
                                  ),
                                ),
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
                        )
                      ],
                    ))))
          ])),
    );
  }
}
