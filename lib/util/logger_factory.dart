import 'package:logger/logger.dart';

var logger = Logger(
  level: Level.debug,
  filter: ProductionFilter(),
  printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true),
);
