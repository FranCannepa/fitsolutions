import 'package:flutter/material.dart';

class ConfirmDialog<T> extends StatefulWidget {
  final GlobalKey<State>? parentKey;
  final String title;
  final String content;
  final Future<T> Function() onConfirm;
  const ConfirmDialog(
      {super.key,
      required this.title,
      required this.content,
      required this.onConfirm, required this.parentKey});

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.content),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () async{
            // Call the onConfirm function
            widget.onConfirm();
            Navigator.of(context).pop();
            
            if(widget.parentKey != null){
              Navigator.of(widget.parentKey!.currentContext!).pop();
            }
          },
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
