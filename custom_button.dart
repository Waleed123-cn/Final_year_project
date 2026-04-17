import 'package:flutter/material.dart';

Widget customButton({
  required Widget text,
  required VoidCallback? onPressed,
  Color color = Colors.red,
  double height = 50,
  double borderRadius = 10,
}) {
  return SizedBox(
    width: double.infinity,
    height: height,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      onPressed: onPressed,
      child: text,
    ),
  );
}
