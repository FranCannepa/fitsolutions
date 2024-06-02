import 'package:flutter/material.dart';

class TimeInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? text;
  const TimeInputField({super.key, required this.text,required this.controller});

  @override
  State<TimeInputField> createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<TimeInputField> {
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateTime);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateTime);
    super.dispose();
  }

  void _updateTime() {
    final text = widget.controller.text;
    final parts = text.split(':');
    if (parts.length == 2) {
      setState(() {
        _minutes = int.tryParse(parts[0]) ?? 0;
        _seconds = int.tryParse(parts[1]) ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          widget.text!,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Minutos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  _minutes = int.tryParse(value) ?? 0;
                  widget.controller.text =
                      '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}';
                }),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Segundos',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() {
                  _seconds = int.tryParse(value) ?? 0;
                  widget.controller.text =
                      '${_minutes.toString().padLeft(2, '0')}:${_seconds.toString().padLeft(2, '0')}';
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
