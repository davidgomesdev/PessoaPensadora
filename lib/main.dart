import 'package:flutter/material.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/ui/screen/reader_screen.dart';

import 'model/category_text.dart';

final dummyCategory = PessoaCategory(
  title: "Very much",
  texts: [PessoaText("Heaven", "Heal")],
  subcategories: [
    PessoaCategory(
      title: "A lot",
      texts: [PessoaText("Thing", "Coise")],
    ),
    PessoaCategory(
      title: "Something",
      texts: [PessoaText("Yooo", "E tal")],
    ),
  ],
);
final index = PessoaIndex(categories: [dummyCategory]);

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: bonitoTheme,
      home: ReaderScreen(index: index),
    );
  }
}
