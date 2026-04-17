import 'package:digifun/routes/route_name.dart';
import 'package:digifun/utilites/image_resource.dart';
import 'package:digifun/controllers/firebase_services/firebase_services_provider.dart';
import 'package:digifun/screens/Auth/widgets/authentication_form.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreentate();
}

class _LoginScreentate extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signIn() async {
    ref.read(isLoadingProvider.notifier).state = true;

    String email = emailController.text;
    String password = passwordController.text;

    final signUpProvider = ref.read(firebaseAuthServiceProvider.notifier);

    try {
      User? user = await signUpProvider.signInWithEmailAndPassword(
        context: context,
        email: email,
        password: password,
      );
      if (user != null) {
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
      print("Sign In error: $e");
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(),
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
                  'Welcome Back!',
                  style: TextStyle(
                    fontFamily: 'Pacifico',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "Let's fun together!",
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
                        loginForm(
                          formKey: formKey,
                          emailController: emailController,
                          passwordController: passwordController,
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              signIn();
                            }
                          },
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
