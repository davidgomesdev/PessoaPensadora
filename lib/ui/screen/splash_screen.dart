import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../bonito_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<String> splashText;
  late Image splashArt;

  @override
  void initState() {
    super.initState();
    splashText = _getRandomSplashText();
    splashArt = Image.asset("assets/images/splash_art.jpg");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        final text = snapshot.data;

        if (snapshot.hasError) {
          snapshot.printError();
          return ErrorWidget(snapshot.error!);
        }

        if (text == null) return Container();

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Expanded(flex: 2, child: Center(child: splashArt)),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  text,
                  style: bonitoTextTheme.bodySmall!
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ],
        );
      },
      future: splashText,
    );
  }

  Future<String> _getRandomSplashText() async {
    final jsonFile =
        await rootBundle.loadString("assets/json_files/splash_texts.json");
    final texts = jsonDecode(jsonFile);

    return texts[Random().nextInt(texts.length)];
  }
}
