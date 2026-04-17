import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digifun/routes/route_name.dart';
import 'package:digifun/utilites/colors.dart';
import 'package:digifun/utilites/image_resource.dart';
import 'package:digifun/controllers/firebase_services/firebase_services_provider.dart';
import 'package:digifun/screens/Auth/widgets/authentication_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _agreeToTerms = false;

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleAgreeToTerms(bool? value) {
    setState(() {
      _agreeToTerms = value ?? false;
    });
  }

  Future<void> initializeUserRewards(String uid) async {
    final docRef = FirebaseFirestore.instance.collection('rewards').doc(uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'points': 50,
        'diamonds': 10,
        'lastClaimed': {},
      });
    }
  }

  void signUp() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.alertColor,
          content: Text(
            "You must agree to the Terms & Conditions",
            style: TextStyle(
              color: AppColors.textPrimaryColor,
            ),
          ),
        ),
      );
      return;
    }

    ref.read(isLoadingProvider.notifier).state = true;

    String email = emailController.text;
    String password = passwordController.text;
    String userName = userNameController.text;
    final signUpProvider = ref.read(firebaseAuthServiceProvider.notifier);

    try {
      User? user = await signUpProvider.signUpWithEmailAndPassword(
        profileImage:
            'https://www.gstatic.com/images/branding/product/1x/avatar_square_blue_512dp.png',
        email: email,
        password: password,
        userName: userName,
        context: context,
      );
      if (user != null) {
        await initializeUserRewards(user.uid);
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteName.navBarScreen,
            (Route<dynamic> route) => false,
          );
        }
      } else {
        print("Error: User sign-up failed.");
      }
    } catch (e) {
      print("Sign up error: $e");
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                  child: const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(ImageRes.digifunLogo),
                  ),
                ),
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Join the fun and start learning!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Raleway',
                  ),
                ),
                authState.when(
                  data: (user) {
                    return Column(
                      children: [
                        signUpForm(
                          formKey: formKey,
                          userNameController: userNameController,
                          emailController: emailController,
                          passwordController: passwordController,
                          confirmPasswordController: confirmPasswordController,
                          onPressed: () {
                            if (formKey.currentState!.validate() &&
                                _agreeToTerms) {
                              signUp();
                            }
                          },
                          buttonTextColor: _agreeToTerms
                              ? AppColors.whiteColor
                              : AppColors.blackColor,
                          agreeToTerms: _agreeToTerms,
                          onAgreeToTermsChanged: _toggleAgreeToTerms,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already registered?',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, RouteName.login);
                              },
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stackTrace) => Text('Error: $error'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
