import 'dart:io';

Future<bool> hasInternet() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    }
  } on SocketException catch (_) {}

  return false;
}

class NoInternetException implements Exception {}

class SourceNotAccessibleException implements Exception {}
