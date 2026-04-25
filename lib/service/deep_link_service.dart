import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';

class DeepLinkService extends GetxController {
  final _appLinks = AppLinks();
  String? _pendingPath;

  String? consumePendingPath() {
    final path = _pendingPath;
    _pendingPath = null;
    return path;
  }

  Future<void> initialize() async {
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      log.i('Deep link on cold start: $initialLink');
      _pendingPath = initialLink.path;
    }

    _appLinks.uriLinkStream.listen((uri) {
      log.i('Deep link while running: $uri');
      _handleUri(uri);
    });
  }

  void _handleUri(Uri uri) {
    final path = uri.path;
    if (RegExp(r'^/textReader/\d+$').hasMatch(path)) {
      Get.toNamed(path);
    }
  }
}
