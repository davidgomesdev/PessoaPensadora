import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

const arquivoPessoaTextUrl = 'http://arquivopessoa.net/textos';

class ArquivoPessoaButton extends StatefulWidget {
  final int textId;

  const ArquivoPessoaButton({super.key, required this.textId});

  @override
  State<ArquivoPessoaButton> createState() => _ArquivoPessoaButtonState();
}

class _ArquivoPessoaButtonState extends State<ArquivoPessoaButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          await launchUrlString('$arquivoPessoaTextUrl/${widget.textId}');
        },
        icon: const Icon(Icons.open_in_new),
        tooltip: 'view_on_arquivo_pessoa'.tr
    );
  }
}
