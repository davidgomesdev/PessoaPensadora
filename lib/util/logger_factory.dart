import 'package:logger/logger.dart';

final log = Logger(
  level: Level.debug,
  filter: ProductionFilter(),
  printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime),
);
