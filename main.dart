import 'package:digifun/routes/route.dart';
import 'package:digifun/firebase_options.dart';
import 'package:digifun/screens/Auth/signup/sign_up_screen.dart';
import 'package:digifun/screens/launch/launch_screen.dart';
import 'package:digifun/screens/navbar_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digi Fun',
      onGenerateRoute: (settings) => Routes.generateRoute(settings),
      home: authState.when(
        data: (user) =>
            user != null ? const NavbarScreen() : const LaunchScreen(),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => const Center(
          child: Text('Error loading app'),
        ),
      ),
    );
  }
}
