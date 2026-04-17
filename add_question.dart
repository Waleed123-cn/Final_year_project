import 'package:digifun/utilites/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionScreen extends StatefulWidget {
  final String userId;

  const AddQuestionScreen({super.key, required this.userId});

  @override
  AddQuestionScreenState createState() => AddQuestionScreenState();
}

class AddQuestionScreenState extends State<AddQuestionScreen> {
  List<Map<String, dynamic>> questions = [];
  TextEditingController quizTitleController = TextEditingController();

  void addNewQuestion() {
    setState(() {
      questions.add({
        "questionText": TextEditingController(),
        "options": List.generate(4, (index) => TextEditingController()),
        "correctOptionIndex": -1,
      });
    });
  }

  bool validateInputs() {
    if (quizTitleController.text.trim().isEmpty) {
      showSnackBar("Please enter a quiz title.");
      return false;
    }
    for (var question in questions) {
      if (question["questionText"].text.trim().isEmpty) {
        showSnackBar("Please enter a question.");
        return false;
      }
      for (var option in question["options"]) {
        if (option.text.trim().isEmpty) {
          showSnackBar("Please enter all options.");
          return false;
        }
      }
      if (question["correctOptionIndex"] == -1) {
        showSnackBar("Please select the correct answer.");
        return false;
      }
    }
    return true;
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void saveQuizToFirebase() async {
    if (questions.isEmpty) {
      showSnackBar("Please add at least one question.");
      return;
    }
    if (!validateInputs()) return;

    CollectionReference quizCollection = FirebaseFirestore.instance
        .collection('quiz')
        .doc(widget.userId)
        .collection('userQuizzes');

    String docId = quizCollection.doc().id;

    List<Map<String, dynamic>> formattedQuestions = questions.map((q) {
      return {
        "question": q["questionText"].text.trim(),
        "options":
            q["options"].map((controller) => controller.text.trim()).toList(),
        "correctOptionIndex": q["correctOptionIndex"],
      };
    }).toList();

    await quizCollection.doc(docId).set({
      "quizTitle": quizTitleController.text.trim(),
      "questions": formattedQuestions,
      "createdAt": FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.alertColor,
        title: const Text(
          "Add Quiz",
          style: TextStyle(color: AppColors.textPrimaryColor),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.whiteColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              "Create New Quiz",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: quizTitleController,
              decoration: inputDecoration("Enter Quiz Title"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: questions[index]["questionText"],
                            decoration: inputDecoration("Enter Question"),
                          ),
                          const SizedBox(height: 10),
                          ...List.generate(4, (i) {
                            return ListTile(
                              title: TextField(
                                controller: questions[index]["options"][i],
                                decoration: inputDecoration("Option ${i + 1}"),
                              ),
                              leading: Radio<int>(
                                value: i,
                                groupValue: questions[index]
                                    ["correctOptionIndex"],
                                onChanged: (value) {
                                  setState(() {
                                    questions[index]["correctOptionIndex"] =
                                        value!;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: addNewQuestion,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Question"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: saveQuizToFirebase,
                  icon: const Icon(
                    Icons.save,
                    color: AppColors.whiteColor,
                  ),
                  label: const Text(
                    "Save Quiz",
                    style: TextStyle(color: AppColors.textPrimaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alertColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
