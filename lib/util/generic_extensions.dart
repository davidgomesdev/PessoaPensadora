extension NullableImprovement<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) getFn) {
    for (final currentElement in this) {
      final result = getFn(currentElement);

      if (result) return currentElement;
    }

    return null;
  }
}

extension ListUtils<E> on List<E> {
  E? getNext(E element) {
    final nextIndex = indexOf(element) + 1;

    if (nextIndex > length) return null;

    return elementAt(nextIndex);
  }

  E? getPrevious(E element) {
    final previousIndex = indexOf(element) - 1;

    if (previousIndex < 0) return null;

    return elementAt(previousIndex);
  }
}
