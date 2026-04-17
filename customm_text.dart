import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

Widget textSize22(
    {required String text,
    Color color = AppColors.blackColor,
    FontWeight font = FontWeight.bold,
    bool aligncenter = true}) {
  return Text(
    text,
    textAlign: aligncenter ? TextAlign.center : TextAlign.start,
    style: TextStyle(
      color: color,
      fontSize: 22,
      fontWeight: font,
    ),
  );
}

Widget textSize14({
  required String text,
  Color color = AppColors.textSeconderyColor,
  bool shouldEllipsize = false,
  FontWeight fontWeight = FontWeight.normal,
  TextOverflow overFlow = TextOverflow.visible,
}) {
  return Text(
    text,
    overflow: shouldEllipsize ? TextOverflow.ellipsis : TextOverflow.visible,
    style: TextStyle(
      color: color,
      fontSize: 14,
      fontWeight: fontWeight,
    ),
  );
}

Widget textSize12({
  required String text,
  Color color = AppColors.textSeconderyColor,
  TextOverflow overflow = TextOverflow.visible,
  FontWeight fontWeight = FontWeight.bold,
}) {
  return Text(
    textAlign: TextAlign.start,
    text,
    style: TextStyle(
      color: color,
      fontSize: 12,
    ),
  );
}

Widget textSize16({
  required String text,
  Color color = AppColors.textSeconderyColor,
  TextOverflow overflow = TextOverflow.visible,
  FontWeight fontWeight = FontWeight.bold,
  TextAlign align = TextAlign.start,
}) {
  return Text(
    textAlign: align,
    text,
    style: TextStyle(
      color: color,
      fontSize: 16,
      fontWeight: fontWeight,
    ),
  );
}

Widget textSize35(
    {required String text,
    Color color = AppColors.whiteColor,
    TextOverflow overflow = TextOverflow.ellipsis}) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: 35, fontWeight: FontWeight.w900),
  );
}

Widget textSize40(
    {required String text,
    Color color = AppColors.whiteColor,
    TextOverflow overflow = TextOverflow.ellipsis}) {
  return Text(
    overflow: overflow,
    text,
    style: TextStyle(color: color, fontSize: 40, fontWeight: FontWeight.w900),
  );
}

Widget textSize20(
    {required String text,
    Color color = AppColors.whiteColor,
    FontWeight fontWeight = FontWeight.bold,
    bool isEllipsize = false}) {
  return Text(
    text,
    overflow: isEllipsize ? TextOverflow.ellipsis : TextOverflow.visible,
    textAlign: TextAlign.center,
    style: TextStyle(
      color: color,
      fontSize: 20,
      fontWeight: fontWeight,
    ),
  );
}

Widget textSize18(
    {required String text,
    Color color = AppColors.whiteColor,
    FontWeight fontWeight = FontWeight.bold,
    TextOverflow overflow = TextOverflow.visible,
    double fontSize = 18}) {
  return Text(
    text,
    softWrap: true,
    style: TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      overflow: overflow,
    ),
  );
}

Widget textSize30({required String text, Color color = Colors.white}) {
  return Text(
    text,
    style: TextStyle(color: color, fontSize: 30, fontWeight: FontWeight.w900),
  );
}

Widget textSize25(
    {required String text,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.bold}) {
  return Text(
    text,
    style: TextStyle(
      color: color,
      fontSize: 25,
      fontWeight: fontWeight,
    ),
  );
}
