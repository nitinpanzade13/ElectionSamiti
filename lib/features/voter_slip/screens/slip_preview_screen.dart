import 'package:flutter/material.dart';

class SlipPreviewScreen extends StatelessWidget {
  // Mock data: Later, this will be passed in from the search screen
  final String voterName = "Rahul Sharma";
  final String voterId = "MH123456789";
  final String constituency = "Pune Cantonment";
  final int wardNumber = 14;
  final int boothNumber = 102;
  final String partNumber = "Part-45";

  const SlipPreviewScreen({super.key});

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
                    _buildInfoRow('Voter Name', voterName),
                    const SizedBox(height: 12),
                    _buildInfoRow('Voter ID', voterId),
                    const SizedBox(height: 12),
                    _buildInfoRow('Constituency', constituency),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Ward / Booth',
                      'Ward $wardNumber  |  Booth $boothNumber',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Part Number', partNumber),
                  ],
                ),
              ),
            ),

            const Spacer(), // Pushes the buttons to the bottom of the screen
            // --- Action Buttons ---
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Trigger Bluetooth Thermal Printer
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connecting to Printer...')),
                );
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
              onPressed: () {
                // TODO: Open WhatsApp with pre-filled message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening WhatsApp...')),
                );
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
