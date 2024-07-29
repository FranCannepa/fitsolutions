import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitsolutions/modelo/Membresia.dart';


class MembresiaAsignada {
  String id;
  int cuposRestantes;
  String estado;
  DateTime fechaCompra;
  DateTime fechaExpiracion;
  Membresia membresia;

  MembresiaAsignada({
    required this.id,
    required this.cuposRestantes,
    required this.estado,
    required this.fechaCompra,
    required this.fechaExpiracion,
    required this.membresia,
  });

  factory MembresiaAsignada.fromData(String id, Map<String, dynamic> data, Membresia membresia) {
    return MembresiaAsignada(
      id: id,
      cuposRestantes: data['cuposRestantes'],
      estado: data['estado'],
      fechaCompra: (data['fechaCompra'] as Timestamp).toDate(),
      fechaExpiracion: (data['fechaExpiracion'] as Timestamp).toDate(),
      membresia: membresia,
    );
  }
}