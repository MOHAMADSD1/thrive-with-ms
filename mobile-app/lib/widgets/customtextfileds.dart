import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';

// ignore: camel_case_types
class customtextfield extends StatelessWidget {
  const customtextfield({
    Key? key,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.validator,
  }) : super(key: key);

  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final String? Function(String?)? validator;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        fillColor: const Color.fromARGB(255, 248, 219, 170),
        filled: true,
        hintText: hint,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }
}
