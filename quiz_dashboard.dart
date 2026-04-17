import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digifun/routes/route_name.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:digifun/utilites/image_resource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class QuizDashboard extends StatefulWidget {
  const QuizDashboard({super.key});

  @override
  State<QuizDashboard> createState() => _QuizDashboardState();
}

class _QuizDashboardState extends State<QuizDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int coins = 0;
  int diamonds = 0;

  @override
  void initState() {
    super.initState();
    fetchRewardsData();
  }

  Future<void> fetchRewardsData() async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print("User is not logged in");
        return;
      }

      DocumentSnapshot rewardDoc = await FirebaseFirestore.instance
          .collection('rewards')
          .doc(userId)
          .get();

      if (rewardDoc.exists) {
        setState(() {
          coins = rewardDoc['points'] ?? 0;
          diamonds = rewardDoc['diamonds'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching reward data: $e");
    }
  }

  Stream<QuerySnapshot> _fetchQuizzes() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return _firestore
        .collection('quiz')
        .doc(userId).collection("userQuizzes")
        .orderBy('createdAt', descending: false)
        .snapshots();
  }

  void _deleteQuiz(String quizId) async {
    try {
      await _firestore.collection('quiz').doc(quizId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: AppColors.alertColor,
            content: Text(
              "Quiz deleted successfully",
              style: TextStyle(color: AppColors.textPrimaryColor),
            )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: AppColors.alertColor,
            content: Text(
              "Error deleting quiz: $e",
              style: const TextStyle(color: AppColors.textPrimaryColor),
            )),
      );
    }
  }

  void _showDeleteConfirmationDialog(String quizId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Quiz"),
          content: const Text("Are you sure you want to delete this quiz?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteQuiz(quizId);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, RouteName.quizAI);
        },
        backgroundColor: AppColors.alertColor,
        icon: const Icon(Icons.auto_awesome_sharp, color: AppColors.whiteColor),
        label: const Text(
          "Generate Quiz",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                const Text(
                  "Custom Quiz",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_sharp, size: 25),
                  onPressed: () {
                    Navigator.pushNamed(context, RouteName.addQuiz);
                  },
                ),
              ],
            ),
          ),
        ],
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Quiz Dashboard',
          style: TextStyle(
              fontFamily: 'Pacifico', fontSize: 24, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Play & Learn',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Image.asset(ImageRes.coinsLogo, height: 24),
                    const SizedBox(width: 5),
                    Text(
                      coins.toString(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 15),
                    Image.asset(ImageRes.diamondLogo, height: 24),
                    const SizedBox(width: 5),
                    Text(
                      diamonds.toString(),
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fetchQuizzes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No quizzes available, let's create one"));
                }

                final quizDocs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: quizDocs.length,
                  itemBuilder: (context, index) {
                    var quiz = quizDocs[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            "${index + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          "${quiz['quizTitle']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "${quiz['questions'].length} Questions",
                        ),
                        trailing: const Icon(Icons.arrow_circle_right,
                            size: 40, color: AppColors.alertColor),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteName.attempQuiz,
                            arguments: "${quiz.id},${quiz["quizTitle"]}",
                          );
                        },
                        onLongPress: () {
                          _showDeleteConfirmationDialog(quiz.id);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
