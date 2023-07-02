import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    required this.controller,
    required this.style,
  });

  final TextEditingController controller;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      validator: (text) {
        if (text == null || text.isEmpty) {
          return 'Text is empty';
        }

        if (int.parse(text.substring(text.length - 2, text.length)) >= 60) {
          return 'Too much seconds';
        }

        if (int.parse(text.substring(0, 2)) >= 60) {
          return 'Too much minutes';
        }

        return null;
      },
      keyboardType: TextInputType.number,
      inputFormatters: [
        MaskedInputFormatter('##:##'),
      ],
      style: style,
      decoration: const InputDecoration(
        hintText: 'mm:ss',
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 0, style: BorderStyle.none),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 0),
        ),
      ),
    );
  }
}
