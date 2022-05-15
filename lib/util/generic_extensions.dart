extension HandyFetching<T> on T {
  R? firstMultiWhere<R>(R? getFn(T self, String param), List<String> params) {
    for (final param in params) {
      final result = getFn(this, param);

      if (result != null) return result;
    }

    return null;
  }
}

extension NullableImprovement<E> on Iterable<E> {
  E? get firstOrNull => isNotEmpty ? first : null;

  E? firstWhereOrNull(bool getFn(E element)) {
    for (final currentElement in this) {
      final result = getFn(currentElement);

      if (result) return currentElement;
    }

    return null;
  }
}
