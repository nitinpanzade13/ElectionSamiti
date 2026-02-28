import 'package:flutter/material.dart';
import '../models/voter_model.dart';
import '../services/message_service.dart';
import '../services/print_service.dart';

class SlipPreviewScreen extends StatelessWidget {
  // 1. Declare the VoterModel variable to hold the real data
  final VoterModel voter;

  // 2. Require it when this screen is opened
  const SlipPreviewScreen({super.key, required this.voter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voter Slip Preview'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- The Digital Slip Card ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'ELECTION SAMITI',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Divider(thickness: 1.5, height: 32),

                    // 3. Inject the real data from your Firestore document!
                    _buildInfoRow('Voter Name', voter.fullName),
                    const SizedBox(height: 12),
                    _buildInfoRow('Voter ID', voter.voterId),
                    const SizedBox(height: 12),
                    _buildInfoRow('Constituency', voter.constituency),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Ward / Booth',
                      'Ward ${voter.wardNumber}  |  Booth ${voter.boothNumber}',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Part Number', voter.partNumber),
                  ],
                ),
              ),
            ),

            const Spacer(), // Pushes the buttons to the bottom of the screen
            // --- Action Buttons ---
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sending to printer...')),
                  );

                  // FIXED: Now passing the correct properties from the 'voter' object
                  await PrintService.printVoterSlip(
                    voterName: voter.fullName,
                    voterId: voter.voterId,
                    constituency: voter.constituency,
                    wardNumber: voter.wardNumber,
                    boothNumber: voter.boothNumber,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              icon: const Icon(Icons.print),
              label: const Text(
                'Print Physical Slip',
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () async {
                try {
                  // FIXED: Now passing the correct properties from the 'voter' object
                  await MessageService.sendSlipViaWhatsApp(
                    voterName: voter.fullName,
                    voterId: voter.voterId,
                    constituency: voter.constituency,
                    wardNumber: voter.wardNumber,
                    boothNumber: voter.boothNumber,
                  );
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              icon: const Icon(Icons.message, color: Colors.green),
              label: const Text(
                'Send via WhatsApp',
                style: TextStyle(fontSize: 16, color: Colors.green),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.green, width: 2),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // A small helper widget to keep the rows clean and aligned
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
