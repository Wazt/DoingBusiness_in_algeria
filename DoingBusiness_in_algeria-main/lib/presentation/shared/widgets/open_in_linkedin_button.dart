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
    // Defense-in-depth: even though the Firestore rules enforce
    // linkedinUrl to match ^https://(www\.)?linkedin\.com/.*, re-validate
    // here so a single lax rule or a compromised admin write can't trigger
    // a deep-link into arbitrary schemes (intent://..., fb://..., etc.).
    // See audit_security_deep_dive.html §07 LOW "launchUrl() without scheme whitelist".
    final Uri uri;
    try {
      uri = Uri.parse(url);
    } on FormatException {
      _showError(context, 'Invalid URL.');
      return;
    }
    if (uri.scheme != 'https' || !uri.host.endsWith('linkedin.com')) {
      _showError(context, 'Refusing to open a non-LinkedIn URL.');
      return;
    }

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // prefer native app
    );
    if (!launched && context.mounted) {
      _showError(context, 'Could not open LinkedIn.');
    }
  }

  void _showError(BuildContext context, String msg) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
