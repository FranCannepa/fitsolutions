import 'package:fitsolutions/components/CommonComponents/result_dialog.dart';
import 'package:flutter/material.dart';

class ModalUtils {
  static void showSuccessModal(BuildContext context, String mensaje, ResultType resultado, VoidCallback onClose) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ResultDialog(text: mensaje, resultType: resultado);
      },
    ).then((_) {
      if (resultado == ResultType.success) {
        onClose();
      }
    });
  }
}