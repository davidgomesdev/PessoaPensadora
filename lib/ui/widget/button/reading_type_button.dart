import 'package:flutter/material.dart';

class ReadingTypeButton extends StatelessWidget {
  final bool isFullReading;
  final void Function(bool changedIsFullReading) onPress;

  const ReadingTypeButton(
      {super.key, required this.isFullReading, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        tooltip: (isFullReading) ? 'Leitura poética' : 'Leitura integral',
        icon: isFullReading
            ? const Icon(Icons.unfold_less_double_rounded)
            : const Icon(Icons.read_more_rounded),
        onPressed: () {
          final newIsFullReading = !isFullReading;
          onPress(newIsFullReading);
        });
  }
}
