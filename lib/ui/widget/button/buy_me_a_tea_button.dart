import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyMeATeaButton extends StatelessWidget {
  const BuyMeATeaButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        tooltip: 'Doar um chá',
        icon: const Icon(Icons.volunteer_activism),
        onPressed: () async {
          await launchUrl(Uri.parse('https://buymeacoffee.com/davidgomes'));
        });
  }
}
