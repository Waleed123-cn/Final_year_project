import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digifun/components/common_widgets/custom_button.dart';
import 'package:digifun/components/common_widgets/customm_text.dart';
import 'package:digifun/routes/route_name.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:digifun/screens/quiz%20screen/widgets/quiz_option_card.dart';
import 'package:digifun/screens/quiz%20screen/widgets/quiz_title_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AttempQuizScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const AttempQuizScreen(
      {super.key, required this.quizId, required this.quizTitle});

  @override
  State<AttempQuizScreen> createState() => _AttempQuizScreenState();
}

class _AttempQuizScreenState extends State<AttempQuizScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerChecked = false;
  int correctAnswers = 0;
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      DocumentSnapshot quizSnapshot = await FirebaseFirestore.instance
          .collection('quiz')
          .doc(userId)
          .collection("userQuizzes")
          .doc(widget.quizId.toString())
          .get();

      if (quizSnapshot.exists) {
        List<dynamic> questionsData = quizSnapshot['questions'];

        List<Map<String, dynamic>> fetchedQuestions =
            questionsData.map((question) {
          return {
            "questionText": question["question"],
            "options": List<String>.from(question["options"]),
            "correctAnswer": question["correctOptionIndex"],
          };
        }).toList();

        setState(() {
          _questions = fetchedQuestions;
          _isLoading = false;
        });
      } else {
        print("Quiz document does not exist");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _goToNextQuestion() {
    if (!_isAnswerChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: AppColors.alertColor,
            content: Text(
              "Please select an option.",
              style: TextStyle(
                color: AppColors.textPrimaryColor,
              ),
            )),
      );
      return;
    }

    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswerChecked = false;
      } else {
        Navigator.pushReplacementNamed(context, RouteName.congratscreen,
            arguments: "$correctAnswers,${_questions.length},${widget.quizId}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    double progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        backgroundColor: AppColors.alertColor,
        title: Text(
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          widget.quizTitle,
          style: const TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 170,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.alertColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
            ),
            Column(
              children: [
                quizTitleCard(
                  totalQuestions:
                      '${_currentQuestionIndex + 1}/${_questions.length}',
                  text: currentQuestion["questionText"],
                  container: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blueAccent),
                    ),
                  ),
                  widget: Column(
                    children: [
                      for (int i = 0;
                          i < currentQuestion['options'].length;
                          i++)
                        GestureDetector(
                          onTap: !_isAnswerChecked
                              ? () {
                                  setState(() {
                                    _selectedOptionIndex = i;
                                    _isAnswerChecked = true;
                                    if (_selectedOptionIndex ==
                                        currentQuestion['correctAnswer']) {
                                      correctAnswers++;
                                    }
                                  });
                                }
                              : null,
                          child: quizOptionCard(
                            optionNumber: (i + 1).toString(),
                            text: currentQuestion['options'][i],
                            color: _isAnswerChecked
                                ? i == currentQuestion['correctAnswer']
                                    ? Colors.green
                                    : (i == _selectedOptionIndex
                                        ? Colors.red
                                        : Colors.grey[300] ?? Colors.grey)
                                : Colors.white,
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 20),
                        child: customButton(
                          text: textSize14(
                            text: "Next Question",
                            color: AppColors.whiteColor,
                          ),
                          onPressed: _goToNextQuestion,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
