import 'package:flutter/material.dart';

class InputTimePicker extends StatefulWidget {
  final String labelText;
  final TimeOfDay? horaSeleccionada;
  final Function(TimeOfDay) onTimeSelected;
  final String? Function(TimeOfDay?)? validator;

  const InputTimePicker(
      {super.key,
      required this.labelText,
      required this.horaSeleccionada,
      required this.onTimeSelected,
      required this.validator});

  @override
  State<InputTimePicker> createState() => _InputTimePickerState();
}

class _InputTimePickerState extends State<InputTimePicker> {
  String selectedTime = "";
  String? errorText;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.horaSeleccionada != null
        ? "${widget.horaSeleccionada!.hour.toString().padLeft(2, '0')}:${widget.horaSeleccionada!.minute.toString().padLeft(2, '0')}"
        : "";
  }

  @override
  Widget build(BuildContext context) {
    return FormField<TimeOfDay>(
        validator: widget.validator,
        builder: (field) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              children: [
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: () async {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: widget.horaSeleccionada ?? TimeOfDay.now(),
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime =
                              "${pickedTime.hour}:${pickedTime.minute}";
                          widget.onTimeSelected(pickedTime);
                          errorText = widget.validator?.call(pickedTime);
                        });
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2.0),
                    ),
                    child: Text(
                        selectedTime.isEmpty ? widget.labelText : selectedTime),
                  ),
                ),
                if (field.errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Container(
                      constraints: BoxConstraints(
                           maxWidth: MediaQuery.of(context).size.width * 0.2), 
                      child: Text(
                        field.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        softWrap: true,
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
  }
}
