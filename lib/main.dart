import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/auth/screens/login_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
// 1. Import our new screen!
import 'features/voter_slip/screens/voter_search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ElectionSamitiApp());
}

class ElectionSamitiApp extends StatelessWidget {
  const ElectionSamitiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElectionSamiti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // We replace the hardcoded "home: const LoginScreen()" with a StreamBuilder
      home: StreamBuilder<User?>(
        // This stream listens to Firebase. If a user is cached, it emits their data.
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. While it's checking, show a loading circle
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              ),
            );
          }

          // 2. If it found a logged-in user, send them straight to the Search Screen!
          if (snapshot.hasData) {
            return const VoterSlipSearchScreen();
          }

          // 3. If no one is logged in, show the Login Screen
          return const LoginScreen();
        },
      ),
    );
  }
}
