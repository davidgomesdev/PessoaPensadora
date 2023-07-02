extension NullableImprovement<E> on Iterable<E> {
  E? get firstOrNull => isNotEmpty ? first : null;

  E? firstWhereOrNull(bool Function(E element) getFn) {
    for (final currentElement in this) {
      final result = getFn(currentElement);

      if (result) return currentElement;
    }

    return null;
  }
}
