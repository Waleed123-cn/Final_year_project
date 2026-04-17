import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:digifun/utilites/image_resource.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FindCardsGameScreen extends StatefulWidget {
  const FindCardsGameScreen({super.key});

  @override
  State<FindCardsGameScreen> createState() => _FindCardsGameScreenState();
}

class CardModel {
  final IconData icon;
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.icon,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class _FindCardsGameScreenState extends State<FindCardsGameScreen> {
  List<CardModel> cards = [];
  List<int> flippedIndices = [];
  int coins = 0;
  int diamonds = 0;

  final List<IconData> allIcons = [
    Icons.star,
    Icons.favorite,
    Icons.cake,
    Icons.ac_unit,
    Icons.pets,
    Icons.directions_bike,
    Icons.airplanemode_active,
    Icons.beach_access,
    Icons.brightness_5,
    Icons.flight,
    Icons.headset,
    Icons.home,
    Icons.lightbulb,
    Icons.local_florist,
    Icons.music_note,
    Icons.pool,
    Icons.sports_esports,
    Icons.work,
  ];

  @override
  void initState() {
    super.initState();
    _generateCards();
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

  void _generateCards() {
    List<IconData> selectedIcons = [...allIcons]..shuffle();
    selectedIcons = selectedIcons.take(6).toList();

    List<CardModel> tempCards = [];
    for (var icon in selectedIcons) {
      tempCards.add(CardModel(icon: icon));
      tempCards.add(CardModel(icon: icon));
    }

    tempCards.shuffle(Random());

    setState(() {
      cards = tempCards;
      flippedIndices.clear();
    });
  }

  void _onCardTap(int index) {
    if (cards[index].isFlipped ||
        cards[index].isMatched ||
        flippedIndices.length == 2) return;

    setState(() {
      cards[index].isFlipped = true;
      flippedIndices.add(index);
    });

    if (flippedIndices.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    int index1 = flippedIndices[0];
    int index2 = flippedIndices[1];

    if (cards[index1].icon == cards[index2].icon) {
      setState(() {
        cards[index1].isMatched = true;
        cards[index2].isMatched = true;
        flippedIndices.clear();
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          cards[index1].isFlipped = false;
          cards[index2].isFlipped = false;
          flippedIndices.clear();
        });
      });
    }
  }

  bool _isGameCompleted() {
    return cards.every((card) => card.isMatched);
  }

  Widget _buildCard(CardModel card, int index) {
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: Card(
        elevation: 4,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.alertColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: card.isFlipped || card.isMatched
                ? Icon(card.icon, size: 40, color: Colors.white)
                : Icon(Icons.help_outline, size: 40, color: Colors.blue[200]),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        backgroundColor: AppColors.alertColor,
        title: const Text(
          'Find Cards',
          style: TextStyle(
            fontFamily: 'Pacifico',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
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
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12,
                right: 12,
                bottom: 12,
              ),
              child: GridView.builder(
                itemCount: cards.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return _buildCard(cards[index], index);
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isGameCompleted()
          ? Padding(
              padding: const EdgeInsets.only(
                bottom: 20,
                left: 20,
                right: 20,
              ),
              child: ElevatedButton(
                onPressed: _generateCards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.alertColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Restart Game",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textPrimaryColor,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
