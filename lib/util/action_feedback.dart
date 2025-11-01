import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

class ActionFeedback {
  static void lightHaptic() {
    if (!kIsWeb) {
      Vibration.vibrate(duration: 75);
    }
  }
}