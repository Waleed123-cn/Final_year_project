import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

class EditProfileTitleCard extends StatelessWidget {
  final String? imagURL;
  final VoidCallback? onTap;

  const EditProfileTitleCard(
      {super.key, required this.imagURL, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                width: 3,
                color: AppColors.alertColor,
              ),
              image: DecorationImage(
                image: NetworkImage(
                  imagURL!,
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 18,
            child: Container(
              height: 30,
              width: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blackColor,
              ),
              child: IconButton(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.edit,
                    size: 15,
                    color: AppColors.whiteColor,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
