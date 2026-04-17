import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digifun/components/common_widgets/customm_text.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:digifun/utilites/image_resource.dart';
import 'package:flutter/material.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  Stream<DocumentSnapshot<Map<String, dynamic>>> _rewardsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }
    return FirebaseFirestore.instance
        .collection('rewards')
        .doc(user.uid)
        .snapshots();
  }

  Future<void> _claimReward(String rewardType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }

    final docRef =
        FirebaseFirestore.instance.collection('rewards').doc(user.uid);
    final snapshot = await docRef.get();
    final data = snapshot.exists ? snapshot.data() ?? {} : {};

    final lastClaimed = data['lastClaimed']?[rewardType] != null
        ? (data['lastClaimed'][rewardType] as Timestamp).toDate()
        : null;

    final now = DateTime.now();
    if (lastClaimed != null && now.difference(lastClaimed).inHours < 24) {
      throw Exception("Reward can only be claimed once every 24 hours.");
    }

    final rewardIncrement = rewardType == "points" ? 10 : 5;
    final updatedValue = (data[rewardType] ?? 0) + rewardIncrement;

    await docRef.set({
      rewardType: updatedValue,
      "lastClaimed": {
        ...?data['lastClaimed'],
        rewardType: now,
      },
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Reward Screen',
          style: TextStyle(
              fontFamily: 'Pacifico', fontSize: 24, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          const Opacity(
            opacity: 0.1,
            child: Center(
              child: CircleAvatar(
                radius: 150,
                backgroundImage: AssetImage(ImageRes.digifunLogo),
              ),
            ),
          ),
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _rewardsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text("Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red)),
                );
              }

              final rewards = snapshot.data?.data() ?? {};
              final int points = rewards["points"] ?? 0;
              final int diamonds = rewards["diamonds"] ?? 0;

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          textSize16(
                              text: "Claim Your Reward",
                              color: AppColors.textSeconderyColor),
                          const Spacer(),
                          Row(
                            children: [
                              Image.asset(ImageRes.coinsLogo,
                                  height: 30, width: 30),
                              const SizedBox(width: 5),
                              Text(points.toString(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Image.asset(ImageRes.diamondLogo,
                                    height: 30, width: 30),
                                const SizedBox(width: 5),
                                Text(diamonds.toString(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildRewardCard(
                      context,
                      "points",
                      "Coins Reward",
                      "Claim 10 Points",
                    ),
                    _buildRewardCard(
                      context,
                      "diamonds",
                      "Diamonds Reward",
                      "Claim 5 Diamonds",
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(BuildContext context, String rewardType, String title,
      String description) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.all(15),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: AppColors.yellowColor,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(ImageRes.digifunLogo, height: 50, width: 50),
              const SizedBox(height: 10),
              textSize16(
                  text: "DigiFun - $title",
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              textSize16(
                  text: description,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _claimReward(rewardType);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          backgroundColor: AppColors.alertColor,
                          content: Text(
                            "Reward claimed successfully!",
                            style: TextStyle(
                              color: AppColors.textPrimaryColor,
                            ),
                          )),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.alertColor,
                        content: Text(
                          "Reward can only be claimed once every 24 hours",
                          style: TextStyle(
                            color: AppColors.textPrimaryColor,
                          ),
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Claim Now"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
