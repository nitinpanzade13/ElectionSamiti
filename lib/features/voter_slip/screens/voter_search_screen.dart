import 'package:flutter/material.dart';
import 'slip_preview_screen.dart';

class VoterSlipSearchScreen extends StatefulWidget {
  const VoterSlipSearchScreen({super.key});

  @override
  State<VoterSlipSearchScreen> createState() => _VoterSlipSearchScreenState();
}

class _VoterSlipSearchScreenState extends State<VoterSlipSearchScreen> {
  // This controller grabs the text the user types into the search bar
  final TextEditingController _voterIdController = TextEditingController();

  @override
  void dispose() {
    _voterIdController.dispose();
    super.dispose();
  }

  void _searchVoter() {
    final voterId = _voterIdController.text.trim();
    if (voterId.isNotEmpty) {
      // Navigate to the Slip Preview Screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SlipPreviewScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Slip Utility'),
        centerTitle: true,
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
            ElevatedButton(
              onPressed: _searchVoter,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: const Text(
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
