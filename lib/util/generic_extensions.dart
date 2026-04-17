extension ListUtils<E> on List<E> {
  E? getNext(E element) {
    try {
      final nextIndex = indexOf(element) + 1;

      if (nextIndex > length) return null;

      return elementAt(nextIndex);
    } on RangeError {
      return null;
    }
  }
}
