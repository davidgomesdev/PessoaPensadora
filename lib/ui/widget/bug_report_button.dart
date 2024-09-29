import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';
import 'package:url_launcher/url_launcher.dart';

const _bugReportNamePrefix = '0-Pessoa-Pensadora-Registo-de-Problemas';

class BugReportButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BugReportButton({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        tooltip: 'Reportar problema',
        icon: const Icon(Icons.report_problem),
        onPressed: () async {
          if (scaffoldKey.currentState?.isDrawerOpen == true) {
            scaffoldKey.currentState?.closeDrawer();
          }

          final time = DateTime.now();
          final name = '$_bugReportNamePrefix-${time.toIso8601String()}.txt';

          var snackBar = SnackBar(
            content: const Text(
                'Escolhe onde pretendes guardar o registo do problema.\nDepois anexa-o no e-mail. ⚠️'),
            action: SnackBarAction(
                label: 'Ok',
                onPressed: () async {
                  final params = SaveFileDialogParams(
                      fileName: name,
                      data: Uint8List.fromList(logStore.toString().codeUnits));
                  final path = await FlutterFileDialog.saveFile(params: params);

                  if (path == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "É necessário guardares o registo para reportar problemas.")));
                    return;
                  }

                  await launchUrl(Uri.parse(
                      'mailto:problemas-app@davidgomes.blog?'
                          'subject=RESUME-O-PROBLEMA-AQUI&'
                          'body=Descreve aqui detalhadamente o problema.\n\n'
                          'Escreve como aconteceu.\n\n'
                          'E inclui screenshots ou '
                          'um video mostrando o que fizeste para o problema surgir, '
                          'para que eu consiga replicar do meu lado.\n\n'
                          "⚠️ Anexa também o ficheiro que guardaste (o nome começa por '0-Pessoa-Pensadora-Registo-de-Problemas')."));
                }),
            duration: const Duration(seconds: 15),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
  }
}
