import 'package:fitsolutions/repository/user_repository.dart';
import 'package:fitsolutions/repository/user_repository_imp.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserRepositoryImp>()])
void main(){
  UserRepository userRepository = MockUserRepositoryImp();

    test('signOut should call FirebaseAuth.signOut', () async {
    // Arrange

    when(userRepository.logOut()).thenAnswer((_) async => Future.value(null));

    await userRepository.logOut();

    verify(userRepository.logOut()).called(1);
  });
}