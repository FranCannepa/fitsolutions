// Mocks generated by Mockito 5.4.4 from annotations
// in fitsolutions/test/widgets/sign_out_widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;
import 'dart:ui' as _i7;

import 'package:cloud_firestore/cloud_firestore.dart' as _i3;
import 'package:firebase_auth/firebase_auth.dart' as _i4;
import 'package:fitsolutions/providers/user_provider.dart' as _i5;
import 'package:logger/logger.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeLogger_0 extends _i1.SmartFake implements _i2.Logger {
  _FakeLogger_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCollectionReference_1<T extends Object?> extends _i1.SmartFake
    implements _i3.CollectionReference<T> {
  _FakeCollectionReference_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUserCredential_2 extends _i1.SmartFake
    implements _i4.UserCredential {
  _FakeUserCredential_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [UserProvider].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserProvider extends _i1.Mock implements _i5.UserProvider {
  @override
  _i2.Logger get log => (super.noSuchMethod(
        Invocation.getter(#log),
        returnValue: _FakeLogger_0(
          this,
          Invocation.getter(#log),
        ),
        returnValueForMissingStub: _FakeLogger_0(
          this,
          Invocation.getter(#log),
        ),
      ) as _i2.Logger);

  @override
  set log(_i2.Logger? _log) => super.noSuchMethod(
        Invocation.setter(
          #log,
          _log,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.CollectionReference<Map<String, dynamic>> get userCollection =>
      (super.noSuchMethod(
        Invocation.getter(#userCollection),
        returnValue: _FakeCollectionReference_1<Map<String, dynamic>>(
          this,
          Invocation.getter(#userCollection),
        ),
        returnValueForMissingStub:
            _FakeCollectionReference_1<Map<String, dynamic>>(
          this,
          Invocation.getter(#userCollection),
        ),
      ) as _i3.CollectionReference<Map<String, dynamic>>);

  @override
  bool get isAuthenticated => (super.noSuchMethod(
        Invocation.getter(#isAuthenticated),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  bool get firstLogin => (super.noSuchMethod(
        Invocation.getter(#firstLogin),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  bool get hasListeners => (super.noSuchMethod(
        Invocation.getter(#hasListeners),
        returnValue: false,
        returnValueForMissingStub: false,
      ) as bool);

  @override
  _i6.Future<void> signIn(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signIn,
          [
            email,
            password,
          ],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<_i4.UserCredential> signUp(
    String? email,
    String? password,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #signUp,
          [
            email,
            password,
          ],
        ),
        returnValue: _i6.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signUp,
            [
              email,
              password,
            ],
          ),
        )),
        returnValueForMissingStub:
            _i6.Future<_i4.UserCredential>.value(_FakeUserCredential_2(
          this,
          Invocation.method(
            #signUp,
            [
              email,
              password,
            ],
          ),
        )),
      ) as _i6.Future<_i4.UserCredential>);

  @override
  _i6.Future<void> resetPassword(String? email) => (super.noSuchMethod(
        Invocation.method(
          #resetPassword,
          [email],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  _i6.Future<void> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  void addListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #addListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void removeListener(_i7.VoidCallback? listener) => super.noSuchMethod(
        Invocation.method(
          #removeListener,
          [listener],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void dispose() => super.noSuchMethod(
        Invocation.method(
          #dispose,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyListeners() => super.noSuchMethod(
        Invocation.method(
          #notifyListeners,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
