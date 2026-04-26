import 'package:web/web.dart';

bool isAndroidBrowser() {
  final ua = window.navigator.userAgent.toLowerCase();
  return ua.contains('android');
}
