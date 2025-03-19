import 'package:flutter/material.dart';

class AlertWidget extends StatelessWidget {
  const AlertWidget({
    Key? key,
    required this.title,
    required this.description,
    this.textOk,
    this.textCancel,
    required this.onOk,
    required this.onCancel,
  }) : super(key: key);

  final String title;
  final String description;
  final String? textOk;
  final String? textCancel;
  final Function onOk;
  final Function onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(
          child: Text(textCancel ?? "Cancelar"),
          onPressed: () => onCancel(),
        ),
        TextButton(
          child: Text(
            textOk ?? "Aceptar",
          ),
          onPressed: () => onOk(),
        ),
      ],
    );
  }
}
