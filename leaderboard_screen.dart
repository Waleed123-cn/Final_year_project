import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsersAndRewards();
  }

  Future<void> _fetchUsersAndRewards() async {
    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('user').get();
      List<Map<String, dynamic>> users = [];

      for (var doc in userSnapshot.docs) {
        String userId = doc.id;
        String userName = doc["userName"] ?? "Unknown";
        String email = doc["email"] ?? "";

        final rewardDoc = await FirebaseFirestore.instance
            .collection('rewards')
            .doc(userId)
            .get();
        final rewardData = rewardDoc.data() ?? {};
        int diamonds = rewardData.containsKey("diamonds")
            ? (rewardData["diamonds"] ?? 0)
            : 0;
        int coins =
            rewardData.containsKey("points") ? (rewardData["points"] ?? 0) : 0;
        int totalPoints = coins + diamonds;

        users.add({
          "userName": userName,
          "email": email,
          "diamonds": diamonds,
          "coins": coins,
          "totalPoints": totalPoints,
        });
      }

      users.sort((a, b) => b["totalPoints"].compareTo(a["totalPoints"]));

      setState(() {
        _users = users;
      });
    } catch (e) {
      debugPrint("Error fetching users and rewards: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: customDrawer(context),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: _users.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.alertColor),
                  SizedBox(height: 10),
                  Text("It may take sometime, please wait..."),
                ],
              ),
            )
          : Column(
              children: [
                if (_users.length >= 3)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTopUserCard(_users[1], 2),
                        _buildTopUserCard(_users[0], 1),
                        _buildTopUserCard(_users[2], 3),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _users.length - 3,
                    itemBuilder: (context, index) {
                      final user = _users[index + 3];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              child: Text("#${index + 4}"),
                            ),
                            title: Text(user["userName"],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(user["email"]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.diamond,
                                    color: Colors.blue, size: 20),
                                Text(" ${user["diamonds"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 10),
                                const Icon(Icons.monetization_on,
                                    color: Colors.amber, size: 20),
                                Text(" ${user["coins"]}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTopUserCard(Map<String, dynamic> user, int rank) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
                rank == 1 ? AppColors.alertColor : AppColors.orangeColor,
            child: Text(
              "#$rank",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            user["userName"].toString().split(" ")[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.diamond, color: Colors.blue, size: 20),
              Text(" ${user["diamonds"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 10),
              const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
              Text(" ${user["coins"]}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
