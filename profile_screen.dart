import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digifun/components/common_widgets/custom_button.dart';
import 'package:digifun/components/common_widgets/customm_text.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:digifun/utilites/image_resource.dart';
import 'package:digifun/controllers/edit-profile/edit_profile_controller.dart';
import 'package:digifun/screens/profile/widgets/edit_profile_title_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _selectAvatar(
      BuildContext context, WidgetRef ref, String userId) async {
    try {
      final avatarsSnapshot =
          await FirebaseFirestore.instance.collection('avatars').get();
      final avatars = avatarsSnapshot.docs
          .map((doc) => doc['avatarUrl'] as String)
          .toList();

      if (avatars.isEmpty) return;

      final selectedAvatar = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: textSize20(text: "Select an Avatar"),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                shrinkWrap: true,
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, avatars[index]);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(avatars[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedAvatar != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();
        final userData = userDoc.data();

        await FirebaseFirestore.instance.collection('user').doc(userId).update({
          "profileImage": selectedAvatar,
          "username": userData?['userName'],
          "email": userData?['email'],
        });

        ref.read(editProfileProvider.notifier).updateProfile(UserData(
              imgURL: selectedAvatar,
              userName: userData?['userName'],
              email: userData?['email'],
            ));
      }
    } catch (e) {
      print("Error fetching avatars: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileData = ref.watch(editProfileProvider);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "";

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Profile Screen',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: profileData.when(
        data: (data) {
          final usernameController =
              TextEditingController(text: data.userName ?? 'No Name');
          final emailController =
              TextEditingController(text: data.email ?? 'example@email.com');
          print("Image url: ${data.imgURL}");

          return Stack(
            children: [
              const Opacity(
                opacity: 0.1,
                child: Center(
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: AssetImage(ImageRes.digifunLogo),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: EditProfileTitleCard(
                        onTap: () => _selectAvatar(context, ref, userId),
                        imagURL: data.imgURL ??
                            'https://www.gstatic.com/images/branding/product/1x/avatar_square_blue_512dp.png',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      readOnly: true,
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 150,
                      child: customButton(
                        height: 30,
                        text: const Text(
                          'Update',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        onPressed: () {
                          final updatedProfile = UserData(
                            userName: usernameController.text,
                            email: emailController.text,
                          );
                          ref
                              .read(editProfileProvider.notifier)
                              .updateProfile(updatedProfile);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.alertColor)),
        error: (error, stackTrace) => const Center(
          child: Text(
            "Something went wrong",
            style: TextStyle(color: AppColors.alertColor, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
