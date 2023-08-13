import 'package:flutter/widgets.dart';

extension EditableTextStateExt on EditableTextState {
  String getSelectedText() {
    final isSelectionEmpty = textEditingValue.selection.start == -1 &&
        textEditingValue.selection.end == -1;

    if (isSelectionEmpty) return '';

    return textEditingValue.selection.textInside(textEditingValue.text);
  }
}
