import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendReqController {
  Future<void> sendFriendRequest(String senderId, String receiverId) async {
    final requestRef = FirebaseFirestore.instance
        .collection('user')
        .doc(receiverId)
        .collection('friendRequests')
        .doc(senderId);

    await requestRef.set({
      'senderId': senderId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Friend request sent!");
  }

  Stream<List<Map<String, dynamic>>> searchUsersByName(String query) async* {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(currentUserId)
        .get();

    Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

    List<String> friends = userData != null && userData.containsKey('friends')
        ? List<String>.from(userData['friends'])
        : [];

    yield* FirebaseFirestore.instance
        .collection('user')
        .where('userName', isGreaterThanOrEqualTo: query)
        .where('userName', isLessThan: '$query\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              var data = doc.data();
              return {
                'userId': doc.id,
                'userName': data['userName'],
                'email': data['email'],
              };
            })
            .where((user) => user['userId'] != currentUserId)
            .where(
              (user) => !friends.contains(user['userId']),
            )
            .toList());
  }
}
