import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/screens/welcome_screen.dart';
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9933),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // While checking auth state, show loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF0F0C29),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF9933),
                ),
              ),
            );
          }

          // If user is logged in, go to main app
          if (snapshot.hasData) {
            return const VoterSlipSearchScreen();
          }

          // If not logged in, show the Welcome Screen
          return const WelcomeScreen();
        },
      ),
    );
  }
}
