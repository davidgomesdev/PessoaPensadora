import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Image splashArt;

  @override
  void initState() {
    super.initState();
    splashArt = Image.asset("assets/images/splash_art.jpg");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Expanded(flex: 2, child: Center(child: splashArt)),
            const Spacer(
              flex: 2,
              ),
          ],
    );
  }
}
