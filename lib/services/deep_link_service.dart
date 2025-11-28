import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:smartassistant_vendedor/screens/reset_password_screen.dart';

class DeepLinkService {
  static AppLinks? _appLinks;

  static void initDeepLinks(BuildContext context) async {
    _appLinks = AppLinks();

    _handleInitialLink(context);
    _handleIncomingLinks(context);
  }

  static void _handleInitialLink(BuildContext context) async {
    try {
      final Uri? initialUri = await _appLinks?.getInitialLink();
      if (initialUri != null) {
        _processDeepLink(initialUri, context);
      }
    } catch (e) {
      print('Error handling initial app link: $e');
    }
  }

  static void _handleIncomingLinks(BuildContext context) {
    _appLinks?.uriLinkStream.listen((Uri uri) {
      _processDeepLink(uri, context);
    });
  }

  static void _processDeepLink(Uri uri, BuildContext context) {
    print('Processing deep link: $uri');

    if (uri.scheme == 'smartassistant' && uri.host == 'reset-password') {
      final token = uri.queryParameters['token'];

      if (token != null && token.isNotEmpty) {
        print('Token recibido: $token');

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(token: token),
          ),
          (route) => false,
        );
      } else {
        print('No token found in deep link');
      }
    }
  }
}
