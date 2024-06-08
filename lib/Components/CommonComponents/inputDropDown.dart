import 'package:flutter/material.dart';

class InputDropdown extends StatefulWidget {
  final String labelText;
  final List<String> options; 
  final TextEditingController
      controller; 

  const InputDropdown({
    super.key,
    required this.labelText,
    required this.options,
    required this.controller,
  });

  @override
  State<InputDropdown> createState() => _InputDropdownState();
}

class _InputDropdownState extends State<InputDropdown> {
  String selectedOption = "Mixto";

  @override
  void initState() {
    super.initState();
    if (widget.options.isNotEmpty) {
      selectedOption = widget.options[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      child: DropdownButtonFormField<String>(
        value: selectedOption,
        decoration: InputDecoration(
          labelText: widget.labelText,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            ),
          ),
        ),
        items: widget.options
            .map((String option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                ))
            .toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedOption = newValue!; 
            widget.controller.text = newValue;
          });
        },
      ),
    );
  }
}
