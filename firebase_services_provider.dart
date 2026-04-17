// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:digifun/components/utilites/colors.dart';

// part 'firebase_service.g.dart';

// @riverpod
// class FirebaseAuthService extends _$FirebaseAuthService {
//   @override
//   Future<User?> build() async {
//     return null;
//   }

//   Future<User?> signUpWithEmailAndPassword(
//       String email,
//       String password,
//       String firstName,
//       String lastName,
//       String profileImage,
//       BuildContext context) async {
//     try {
//       UserCredential credential =
//           await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       User? user = credential.user;

//       if (user != null) {
//         DocumentSnapshot userDoc = await FirebaseFirestore.instance
//             .collection("user")
//             .doc(user.uid)
//             .get();

//         if (!userDoc.exists) {
//           await FirebaseFirestore.instance
//               .collection("user")
//               .doc(user.uid)
//               .set({
//             'firstname': firstName,
//             'lastname': lastName,
//             'createdAt': FieldValue.serverTimestamp(),
//             'email': user.email,
//             'profileImage': profileImage,
//           });
//         }
//       }

//       return user;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('The password provided is too weak.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       } else if (e.code == 'email-already-in-use') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//               'The account already exists for that email.',
//               overflow: TextOverflow.ellipsis,
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       print("Error: $e");
//     }
//     return null;
//   }

// Future<User?> loginUser(
//   String email,
//   String password,
//   BuildContext context,
// ) async {
//   try {
//     UserCredential userCredential = await FirebaseAuth.instance
//         .signInWithEmailAndPassword(email: email, password: password);
//     return userCredential.user;
//   } on FirebaseAuthException catch (e) {
//     if (e.code == 'user-not-found') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('No user found for that email.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } else if (e.code == 'wrong-password') {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Wrong password provided for that user.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Something went wrong.'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//     return null;
//   }
// }

//   Future<void> sendPasswordResetEmail(
//       String email, BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Password reset email sent'),
//             backgroundColor: AppColors.alertColor),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: ${e.toString()}'),
//           backgroundColor: AppColors.alertColor,
//         ),
//       );
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_services_provider.g.dart';

@riverpod
class FirebaseAuthService extends _$FirebaseAuthService {
  @override
  Future<User?> build() async {
    return null;
  }

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String userName,
    required BuildContext context,
    required String profileImage,
  }) async {
    try {
      UserCredential credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("user")
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection("user")
              .doc(user.uid)
              .set({
            'userName': userName,
            'createdAt': FieldValue.serverTimestamp(),
            'email': user.email,
            'profileImage': profileImage,
          });
        }
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('The password provided is too weak.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The account already exists for that email.',
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No user found for that email.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong password provided for that user.'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }
}
