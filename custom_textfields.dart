import 'package:flutter/material.dart';

Widget customTextField({
  required String hintText,
  required IconData icon,
  bool isObscure = false,
  Widget? suffixIcon,
  required TextEditingController controller,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      filled: true,
      suffixIcon: suffixIcon,
    ),
    obscureText: isObscure,
    validator: validator,
  );
}
