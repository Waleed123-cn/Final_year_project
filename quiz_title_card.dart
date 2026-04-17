import 'package:digifun/components/common_widgets/customm_text.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

Widget quizTitleCard({
  required Widget container,
  required Widget widget,
  required String text,
  required String totalQuestions,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.purple[100],
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textSize14(
                text: "Quiz 1",
                fontWeight: FontWeight.bold,
              ),
              textSize14(text: totalQuestions, fontWeight: FontWeight.bold)
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 30,
                ),
                child:
                    textSize20(text: text, color: AppColors.textSeconderyColor),
              ),
              Container(
                child: container,
              ),
            ],
          ),
        ),
        widget,
      ],
    ),
  );
}
