import 'package:vibration/vibration.dart';

class ActionFeedback {
  /// Forces haptic feedback even when it's disabled in the settings. (on Android)
  static void lightHaptic() {
    Vibration.vibrate(duration: 75);
  }
}