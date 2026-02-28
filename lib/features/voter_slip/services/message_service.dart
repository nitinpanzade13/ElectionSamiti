import 'package:url_launcher/url_launcher.dart';

class MessageService {
  /// Opens WhatsApp with a pre-filled message containing the voter's slip details.
  /// Note: The phone parameter should include the country code (e.g., "+919876543210").
  static Future<void> sendSlipViaWhatsApp({
    required String voterName,
    required String voterId,
    required String constituency,
    required int wardNumber,
    required int boothNumber,
    String?
    phoneNumber, // Optional: if the worker knows it, it opens their exact chat
  }) async {
    // 1. Format the text exactly how you want it to look on the voter's phone
    final String message =
        '''
🗳️ *ELECTION SAMITI* 🗳️
Hello $voterName, here are your voting details:

🆔 *Voter ID:* $voterId
📍 *Constituency:* $constituency
🏘️ *Ward:* $wardNumber
🏢 *Booth Number:* $boothNumber

Please bring your valid ID proof to the polling booth. Thank you!
''';

    // 2. Encode the text so it can safely travel inside a URL
    final String encodedMessage = Uri.encodeComponent(message);

    // 3. Construct the WhatsApp URL
    // If we have a phone number, send it directly to them. Otherwise, open the app so the worker can pick a contact.
    final String urlString = phoneNumber != null && phoneNumber.isNotEmpty
        ? 'https://wa.me/$phoneNumber?text=$encodedMessage'
        : 'https://wa.me/?text=$encodedMessage';

    final Uri whatsappUrl = Uri.parse(urlString);

    // 4. Launch the app!
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception(
        'Could not launch WhatsApp. Is it installed on this device?',
      );
    }
  }
}
