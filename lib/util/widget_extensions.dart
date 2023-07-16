import 'package:flutter/widgets.dart';

extension EditableTextStateExt on EditableTextState {
  String getSelectedText() {
    return textEditingValue.selection.textInside(textEditingValue.text);
  }
}
