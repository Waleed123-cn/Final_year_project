import 'package:digifun/screens/dashboard/widget/game_card.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

Widget gameCardWithLock(
  BuildContext context,
  String name,
  String image,
  bool isUnlocked,
  bool isLoading,
  VoidCallback onTap,
) {
  return isLoading
      ? Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
        )
      : InkWell(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              gameCard(
                context,
                Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
                name,
                onTap,
              ),
              if (!isUnlocked)
                const CircleAvatar(
                  backgroundColor: AppColors.whiteColor,
                  child: Icon(
                    Icons.lock,
                    size: 25,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        );
}
