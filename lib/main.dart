import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      // 2. Set the home property to our new search screen
      home: const VoterSlipSearchScreen(),
    );
  }
}
