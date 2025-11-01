import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final logStore = StringBuffer();

final log = Logger(
  level: Level.debug,
  output: SavedConsoleOutput(),
  filter: ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: kIsWeb ? 0 : 1,
    errorMethodCount: kIsWeb ? 0 : 5,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    dateTimeFormat: DateTimeFormat.dateAndTime,
  ),
);

class SavedConsoleOutput implements LogOutput {
  final _consoleOutput = ConsoleOutput();

  @override
  void output(OutputEvent event) {
    logStore.writeAll(event.lines, kIsWeb ? "\n" : Platform.lineTerminator);
    _consoleOutput.output(event);
  }

  @override
  Future<void> destroy() async {
    await _consoleOutput.destroy();
    logStore.clear();
  }

  @override
  Future<void> init() async {
    await _consoleOutput.init();
  }
}
