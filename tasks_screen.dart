import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digifun/utilites/image_resource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:digifun/utilites/colors.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Map<String, dynamic>> healthTasks = [
    {
      "title": "Running",
      "description": "Run for at least 20 minutes daily.",
      "icon": ImageRes.running,
    },
    {
      "title": "Exercise",
      "description": "Do a full-body workout for 30 minutes.",
      "icon": ImageRes.workout,
    },
    {
      "title": "Walking",
      "description": "Walk 10,000 steps a day for a healthy heart.",
      "icon": ImageRes.walking
    },
    {
      "title": "Push-ups",
      "description": "Complete 50 push-ups in sets.",
      "icon": ImageRes.pushUps
    },
    {
      "title": "Yoga",
      "description": "Practice yoga for flexibility and relaxation.",
      "icon": ImageRes.yoga
    },
    {
      "title": "Meditation",
      "description": "Spend 15 minutes in mindfulness meditation.",
      "icon": ImageRes.meditation
    },
    {
      "title": "Hydration",
      "description": "Drink at least 8 glasses of water daily.",
      "icon": ImageRes.hydration
    },
  ];

  Map<String, DateTime> completedTasks = {};
  Map<String, bool> isLoadingTask = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCompletedTasks();
  }

  Future<void> loadCompletedTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('rewards')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      Map<String, dynamic>? data = doc.data();
      if (data != null && data['completedTasks'] != null) {
        Map<String, dynamic> storedTasks = data['completedTasks'];
        storedTasks.forEach((key, value) {
          completedTasks[key] = (value as Timestamp).toDate();
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  bool isTaskDisabled(String title) {
    if (completedTasks.containsKey(title)) {
      final lastTime = completedTasks[title]!;
      return DateTime.now().difference(lastTime).inHours < 24;
    }
    return false;
  }

  Future<void> markAsComplete(int index) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String title = healthTasks[index]["title"];

    setState(() {
      isLoadingTask[title] = true;
    });

    try {
      final rewardRef =
          FirebaseFirestore.instance.collection('rewards').doc(user.uid);

      final doc = await rewardRef.get();
      int currentCoins = doc.data()?['points'] ?? 0;

      await rewardRef.set({
        'points': currentCoins + 5,
        'completedTasks': {
          title: Timestamp.now(),
        },
      }, SetOptions(merge: true));

      setState(() {
        completedTasks[title] = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You earned 5 coins!"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong!"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoadingTask[title] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Health Tasks',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: healthTasks.length,
              itemBuilder: (context, index) {
                String title = healthTasks[index]["title"];
                bool isDisabled = isTaskDisabled(title);

                return Card(
                  color: isDisabled ? Colors.green[100] : Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(
                        isDisabled
                            ? ImageRes.correct
                            : healthTasks[index]["icon"],
                      ),
                    ),
                    title: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: isDisabled
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    subtitle: Text(
                      healthTasks[index]["description"],
                      style: TextStyle(
                        decoration: isDisabled
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    trailing: isDisabled
                        ? const Icon(Icons.lock_clock,
                            color: Colors.grey, size: 30)
                        : ElevatedButton(
                            onPressed: isLoadingTask[title] == true
                                ? null
                                : () => markAsComplete(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.alertColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isLoadingTask[title] == true
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.textPrimaryColor),
                                    ),
                                  )
                                : const Text(
                                    "Mark as complete",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textPrimaryColor,
                                    ),
                                  ),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
