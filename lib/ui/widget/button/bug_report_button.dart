import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:get/get.dart';
import 'package:pessoa_pensadora/util/logger_factory.dart';
import 'package:url_launcher/url_launcher.dart';

const _bugReportNamePrefix = '0-Pessoa-Pensadora-Registo-de-Problemas';

class BugReportButton extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BugReportButton({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        tooltip: 'report_a_problem'.tr,
        icon: const Icon(Icons.report_problem),
        onPressed: () async {
          if (scaffoldKey.currentState?.isDrawerOpen == true) {
            scaffoldKey.currentState?.closeDrawer();
          }

          final time = DateTime.now();
          final name = '$_bugReportNamePrefix-${time.toIso8601String()}.txt';

          var snackBar = SnackBar(
            content: Text('choose_where_to_save'.tr),
            action: SnackBarAction(
                label: 'ok'.tr,
                onPressed: () async {
                  final params = SaveFileDialogParams(
                      fileName: name,
                      data: Uint8List.fromList(logStore.toString().codeUnits));
                  final path = await FlutterFileDialog.saveFile(params: params);

                  if (path == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('report_a_problem_desc'.tr)));
                    return;
                  }

                  await launchUrl(
                      Uri.parse('mailto:problemas-app@davidgomes.blog?'
                          'subject=${'report_a_problem_email_subject'.tr}&'
                          'body=${'report_a_problem_email_body'.tr}'));
                }),
            duration: const Duration(seconds: 15),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
  }
}
