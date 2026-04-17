import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:digifun/utilites/colors.dart';

class CongratsScreen extends StatefulWidget {
  final int correctAnswers;
  final int totalQuestions;
  final String quizId;

  const CongratsScreen({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.quizId,
  });

  @override
  CongratsScreenState createState() => CongratsScreenState();
}

class CongratsScreenState extends State<CongratsScreen> {
  bool _isLoading = false;

  Future<void> _saveResultsToFirebase(double percentage) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      final userDoc =
          FirebaseFirestore.instance.collection('rewards').doc(user.uid);
      final snapshot = await userDoc.get();
      final existingData =
          snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};

      final int currentPoints = existingData["points"] ?? 0;
      final int currentDiamonds = existingData["diamonds"] ?? 0;
      final int newPoints = currentPoints + widget.correctAnswers;
      final int newDiamonds =
          percentage >= 80 ? currentDiamonds + 2 : currentDiamonds;

      await userDoc.set({"points": newPoints, "diamonds": newDiamonds},
          SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving results to Firebase: $e");
    }
  }

  Future<void> _handleReTakeQuiz(double percentage) async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      await FirebaseFirestore.instance
          .collection('quiz')
          .doc(user.uid)
          .collection("userQuizzes")
          .doc(widget.quizId)
          .delete();

      await _saveResultsToFirebase(percentage);
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double percentage =
        (widget.correctAnswers / widget.totalQuestions) * 100;

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration,
                    size: 80, color: AppColors.alertColor),
                const SizedBox(height: 20),
                const Text(
                  "🎉 Congratulations! 🎉",
                  style: TextStyle(
                    color: AppColors.alertColor,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Pacifico",
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.alertColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.alertColor.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "You answered ${widget.correctAnswers} out of ${widget.totalQuestions} questions correctly!",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Your Score: ${percentage.toStringAsFixed(2)}%",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.alertColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.alertColor)
                    : OutlinedButton(
                        onPressed: () => _handleReTakeQuiz(percentage),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(
                              color: AppColors.alertColor, width: 2),
                          foregroundColor: AppColors.alertColor,
                        ),
                        child: const Text(
                          "Re-Take Quiz",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
