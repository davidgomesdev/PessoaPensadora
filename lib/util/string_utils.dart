String substringBefore(String text, String delimiter) {
  if (!text.contains(delimiter)) {
    return text;
  }

  return text.substring(0, text.indexOf(delimiter));
}
