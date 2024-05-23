import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String labelText;
  final TextEditingController inputControl;
  final bool obscureText;
  final Widget? child; 

  const CustomTextfield(
      {super.key,
      required this.labelText,
      required this.inputControl,
      required this.obscureText,
      required this.child,
      });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
      child: SizedBox(
        width: double.infinity,
        child: TextFormField(
          controller: widget.inputControl,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
            labelText: widget.labelText,
            labelStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF57636C),
              fontSize: 14,
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFE0E3E7),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFF4B39EF),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFFF5963),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFFF5963),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(24),
            suffixIcon: widget.child
          ),
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Color(0xFF101213),
            fontSize: 14,
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
          ),
          keyboardType: TextInputType.emailAddress,
          cursorColor: const Color(0xFF4B39EF),
        ),
      ),
    );
  }
}
