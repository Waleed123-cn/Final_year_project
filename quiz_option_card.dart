import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

Widget quizOptionCard({
  required String text,
  required String optionNumber,
  Color color = AppColors.whiteColor,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 8, top: 8, bottom: 8),
      child: Row(
        children: [
          Text(
            optionNumber,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
