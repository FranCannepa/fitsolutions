import 'package:fitsolutions/modelo/user_data.dart';
import 'package:fitsolutions/screens/Login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';

import 'sign_in_widget_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserData>()])
void main() {
  UserData provider = MockUserData();

  Widget _makeTestable(Widget child) {
    return ChangeNotifierProvider<UserData>.value(
        value: provider,
        child: MaterialApp(
          home: child,
        ));
  }

  var signInButton = find.text('Continuar con Google');

  group('login screen test', () {
    testWidgets('Sign In with Google button found',
        (WidgetTester tester) async {
      await tester.pumpWidget(_makeTestable(const LoginScreen()));
      expect(signInButton, findsOneWidget);
    });
  });
}
