import 'package:digifun/components/common_widgets/customm_text.dart';
import 'package:digifun/routes/route_name.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:digifun/controllers/edit-profile/edit_profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Widget customDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        Consumer(
          builder: (context, ref, child) {
            final profileData = ref.watch(editProfileProvider);
            return DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.alertColor),
              curve: Curves.bounceIn,
              child: profileData.when(
                data: (data) {
                  return ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.whiteColor,
                      child: Icon(Icons.person, size: 25),
                    ),
                    title: Text(
                      "${data.userName}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimaryColor),
                    ),
                    subtitle: Text(
                      data.email!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimaryColor),
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return Center(
                    child: textSize18(text: "Something went wrong"),
                  );
                },
                loading: () => const Center(
                    child: CircularProgressIndicator(
                  color: AppColors.whiteColor,
                )),
              ),
            );
          },
        ),
        signOut(),
      ],
    ),
  );
}

Widget signOut() {
  return Consumer(
    builder: (context, ref, child) {
      final User? user = FirebaseAuth.instance.currentUser;
      return ListTile(
        leading: const Icon(
          Icons.logout,
          color: AppColors.blackColor,
        ),
        title: const Text('Logout'),
        onTap: () async {
          print({user!.providerData});
          for (var userInfo in user.providerData) {
            switch (userInfo.providerId) {
              case 'password':
                await FirebaseAuth.instance.signOut();
                print('Signed out with Email/Password');
                break;

              default:
                print('Signed out with ${userInfo.providerId}');
                break;
            }
          }

          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteName.signUp,
            (route) => false,
          );
        },
      );
    },
  );
}
