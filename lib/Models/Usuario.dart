import 'package:equatable/equatable.dart';

abstract class Usuario extends Equatable {
  final String id;
  final DateTime dateCreated;
  final String email;

  const Usuario(
      {required this.id, required this.dateCreated, required this.email});
}
