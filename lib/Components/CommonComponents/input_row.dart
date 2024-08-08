
import 'package:flutter/material.dart';

class RowInput extends StatefulWidget {
  final List<TextEditingController> comidasController;
  final TextEditingController maxCaloriasController;
  final List<TextEditingController> dayControllers;
  final List<TextEditingController> mealTypeControllers;
  final List<TextEditingController> kcalControllers;

  const RowInput({
    super.key,
    required this.comidasController,
    required this.maxCaloriasController,
    required this.dayControllers,
    required this.mealTypeControllers,
    required this.kcalControllers,
  });

  @override
  State<RowInput> createState() => RowInputState();
}

class RowInputState extends State<RowInput> {
  final List<String> _mealTypes = ['Desayuno', 'Almuerzo', 'Cena'];
  final List<String> _days = ['1', '2', '3', '4', '5', '6', '7'];
  final List<String> _errors = [];

  void _addFoodInput() {
    setState(() {
      widget.comidasController.add(TextEditingController());
      widget.dayControllers.add(TextEditingController(text: _days[0]));
      widget.mealTypeControllers
          .add(TextEditingController(text: _mealTypes[0]));
      widget.kcalControllers.add(TextEditingController());
      _errors.add('');
    });
  }

  void _removeFoodInput() {
    if (widget.comidasController.isNotEmpty) {
      setState(() {
        widget.comidasController.removeLast();
        widget.dayControllers.removeLast();
        widget.mealTypeControllers.removeLast();
        widget.kcalControllers.removeLast();
        _errors.removeLast();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    for(int i = 0; i < widget.comidasController.length; i++){
      _errors.add('');
    }
  }

  void _validateKcal(int index) {
      String selectedDay = widget.dayControllers[index].text;
      int totalKcal = 0;
      for (int i = 0; i < widget.comidasController.length; i++) {
        if (widget.dayControllers[i].text == selectedDay) {
          totalKcal += int.tryParse(widget.kcalControllers[i].text) ?? 0;
        }
      }
      int maxCalorias = int.tryParse(widget.maxCaloriasController.text) ?? 0;
      if (totalKcal > maxCalorias) {
        setState(() {
          _errors[index] = 'Kcal no puede exceder $maxCalorias';
        });
      } else {
        setState(() {
          _errors[index] = '';  
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          for (int i = 0; i < widget.comidasController.length; i++) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: widget.comidasController[i],
                          decoration: InputDecoration(
                            labelText: 'Comida ${i + 1}',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingrese una comida.';
                            }
                            return null; 
                          },
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: TextFormField(
                          controller: widget.kcalControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Kcal',
                            errorText: _errors.isEmpty || _errors[i].isEmpty
                                ? null
                                : _errors[i],
                          ),
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if(val == null || val.isEmpty){
                              return 'Ingrese un valor de calorias';
                            }
                            int? kcal =int.tryParse(widget.kcalControllers[i].text);
                            if (kcal == null) {
                              return 'El valor debe ser numerico';
                            }
                            if (kcal <= 0) {
                              return 'Kcal debe ser un valor positivo';
                            }
                            _validateKcal(i);
                            return _errors[i] == '' ? null : _errors[i];
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: widget.dayControllers[i].text.isEmpty
                              ? _days.isNotEmpty
                                  ? _days[0]
                                  : null
                              : widget.dayControllers[i].text,
                          items: _days.map((String day) {
                            return DropdownMenuItem<String>(
                              value: day,
                              child: Text(day),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              widget.dayControllers[i].text = newValue!;
                            });
                          },
                          decoration: const InputDecoration(labelText: 'Día'),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: widget.mealTypeControllers[i].text.isEmpty
                              ? _mealTypes.isNotEmpty
                                  ? _mealTypes[0]
                                  : null
                              : widget.mealTypeControllers[i].text,
                          items: _mealTypes.map((String mealType) {
                            return DropdownMenuItem<String>(
                              value: mealType,
                              child: Text(mealType),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              widget.mealTypeControllers[i].text = newValue!;
                            });
                          },
                          decoration: const InputDecoration(
                              labelText: 'Tipo de comida'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
          ],
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addFoodInput,
              ),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: widget.comidasController.length > 1
                    ? _removeFoodInput
                    : null,
                disabledColor:
                    widget.comidasController.length > 1 ? null : Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
