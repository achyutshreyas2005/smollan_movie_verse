import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLauncherUtil {
  static Future<void> launchUrlString(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.isEmpty) {
      _showError(context, 'Streaming link unavailable');
      return;
    }

    final uri = Uri.tryParse(urlString);
    if (uri == null) {
      _showError(context, 'Invalid streaming link');
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        _showError(context, 'Could not open link');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Streaming link unavailable');
    }
  }

  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
