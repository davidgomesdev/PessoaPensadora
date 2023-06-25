extension RegexExtension on String {
  String removeTitle() => replaceAll(
      RegExp(r'(?<!.\n)(?:^.+\n\n)+(?=.+\n\n|.+\n)', multiLine: true), '');
}
