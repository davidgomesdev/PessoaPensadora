String substringBefore(String text, String delimiter) {
  if (!text.contains(delimiter)) {
    return text;
  }

  return text.substring(0, text.indexOf(delimiter));
}

String timeFmt(int ts) {
  final d = DateTime.now().millisecondsSinceEpoch - ts;
  if (d < 60000) return 'agora mesmo';
  if (d < 3600000) return 'há ${d ~/ 60000}min';
  if (d < 86400000) return 'há ${d ~/ 3600000}h';
  return 'há ${d ~/ 86400000}d';
}

