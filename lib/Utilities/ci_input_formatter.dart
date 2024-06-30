import 'package:flutter/services.dart';

class CIInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (text.length > 8) {
      return oldValue;
    }

    String newText = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.length > 1) {
      newText = '${newText.substring(0, 1)}.${newText.substring(1)}';
    }
    if (newText.length > 5) {
      newText = '${newText.substring(0, 5)}.${newText.substring(5)}';
    }
    if (newText.length > 9) {
      newText = '${newText.substring(0, 9)}-${newText.substring(9)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}