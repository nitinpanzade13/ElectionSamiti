import 'package:flutter/material.dart';
import 'slip_preview_screen.dart';

import '../../auth/services/auth_service.dart';
import '../services/voter_service.dart';
import '../models/voter_model.dart';

class VoterSlipSearchScreen extends StatefulWidget {
  const VoterSlipSearchScreen({super.key});

  @override
  State<VoterSlipSearchScreen> createState() => _VoterSlipSearchScreenState();
}

class _VoterSlipSearchScreenState extends State<VoterSlipSearchScreen> {
  // Controllers and Services
  final TextEditingController _voterIdController = TextEditingController();
  final AuthService _authService = AuthService();
  final VoterService _voterService = VoterService();

  // Loading state to show the spinner
  bool _isLoading = false;

  @override
  void dispose() {
    _voterIdController.dispose();
    super.dispose();
  }

  void _searchVoter() async {
    final voterId = _voterIdController.text.trim();
    if (voterId.isEmpty) return;

    // 1. Start the loading spinner
    setState(() {
      _isLoading = true;
    });

    // 2. Fetch the real data from Firestore!
    VoterModel? fetchedVoter = await _voterService.getVoterById(voterId);

    // 3. Stop the loading spinner
    setState(() {
      _isLoading = false;
    });

    // 4. Handle the result
    if (fetchedVoter != null) {
      // Success! Send the voter data to the Preview Screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SlipPreviewScreen(voter: fetchedVoter),
          ),
        );
      }
    } else {
      // Failed! Voter ID does not exist in the database
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voter ID not found in database!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Slip Utility'),
        centerTitle: true,
        actions: [
          // --- Log Out Button ---
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: () async {
              await _authService.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.how_to_vote, size: 80, color: Colors.indigo),
            const SizedBox(height: 32),
            const Text(
              'Enter Voter ID to fetch the digital slip',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // --- Search Input ---
            SearchBar(
              controller: _voterIdController,
              hintText: 'e.g. MH1234567',
              leading: const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: Icon(Icons.search),
              ),
              onSubmitted: (_) => _searchVoter(),
            ),
            const SizedBox(height: 32),

            // --- Fetch Button with Loading State ---
            ElevatedButton(
              onPressed: _isLoading ? null : _searchVoter,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Fetch Voting Slip',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
