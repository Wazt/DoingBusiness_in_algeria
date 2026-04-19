import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// ════════════════════════════════════════════════════════════════════════
///  OpenInLinkedInButton — CTA to open the original post in LinkedIn app
/// ════════════════════════════════════════════════════════════════════════
///  Behavior:
///   1. Try to open the LinkedIn app (deep link via https://linkedin.com/...)
///      Both iOS + Android intercept linkedin.com URLs if the app is installed.
///   2. Fall back to browser otherwise.
///
///  Shown on any article with source == linkedin in the reader screen.
/// ════════════════════════════════════════════════════════════════════════

class OpenInLinkedInButton extends StatelessWidget {
  final String url;
  final bool expanded;

  const OpenInLinkedInButton({
    super.key,
    required this.url,
    this.expanded = true,
  });

  Future<void> _open(BuildContext context) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // prefer native app
    );
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open LinkedIn.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const linkedinBlue = Color(0xFF0A66C2);
    final button = ElevatedButton.icon(
      onPressed: () => _open(context),
      icon: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
        ),
        alignment: Alignment.center,
        child: const Text(
          'in',
          style: TextStyle(
            color: linkedinBlue,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            height: 1,
          ),
        ),
      ),
      label: const Text('Open on LinkedIn'),
      style: ElevatedButton.styleFrom(
        backgroundColor: linkedinBlue,
        foregroundColor: Colors.white,
        minimumSize: expanded ? const Size(double.infinity, 52) : null,
      ),
    );
    return expanded ? button : Align(alignment: Alignment.centerLeft, child: button);
  }
}
