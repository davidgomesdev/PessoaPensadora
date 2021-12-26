import 'package:flutter/material.dart';
import 'package:pessoa_bonito/ui/bonito_theme.dart';
import 'package:pessoa_bonito/ui/screen/reader_screen.dart';

import 'model/category_text.dart';

final dummyCategory = PessoaCategory(
  title: "O GUARDADOR DE REBANHOS",
  texts: [
    PessoaText("Estas quatro canções, escrevi-as estando doente.", """
[XVa]

Estas quatro canções, escrevi-as estando doente.
Agora ficaram escritas e não penso mais nelas.
Gozemos, se pudermos, a nossa doença,
Mas nunca a achemos saúde,
Como os homens fazem.

O defeito dos homens não é serem doentes:
É chamarem saúde à sua doença,
E por isso não buscarem a cura
Nem realmente saberem o que é saúde e doença.
      """)
  ],
  subcategories: [
    PessoaCategory(
      title: "Very much",
      texts: [PessoaText("Heaven", "Heal")],
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
