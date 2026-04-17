import 'package:flutter/material.dart';
import 'package:pessoa_pensadora/util/generic_extensions.dart';

enum SearchReadFilter {
  all('Todos', Icons.book),
  unread('Apenas não lidos', Icons.chrome_reader_mode_outlined),
  read('Apenas lidos', Icons.chrome_reader_mode);

  final String label;
  final IconData icon;

  const SearchReadFilter(this.label, this.icon);

  SearchReadFilter next() =>
      SearchReadFilter.values.getNext(this) ?? SearchReadFilter.values.first;
}
