import 'package:url_launcher/url_launcher.dart';

class ExternalLinkService {
  const ExternalLinkService._();

  static bool shouldOpenExternally(Uri uri) {
    if (uri.scheme == 'http' || uri.scheme == 'https') return false;
    return uri.scheme.isNotEmpty;
  }

  static Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
