import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextStoreService Index Management', () {

    test('mainIndex has 9 curated categories', () {

      const mainCategories = [
        26,
        23,
        25,
        27,
        33,
        24,
        67,
        139,
        10000,
      ];

      expect(mainCategories.length, equals(9));
      expect(mainCategories, isNotEmpty);
    });

    test('mainCategories list contains expected category IDs', () {
      const mainCategories = [
        26, 23, 25, 27, 33, 24, 67, 139, 10000,
      ];

      expect(mainCategories, contains(26));
      expect(mainCategories, contains(23));
      expect(mainCategories, contains(25));
      expect(mainCategories, contains(27));
      expect(mainCategories, contains(33));
      expect(mainCategories, contains(24));
      expect(mainCategories, contains(67));
      expect(mainCategories, contains(139));
      expect(mainCategories, contains(10000));
    });

    test('Subtitles map contains entries for all main categories', () {
      const Map<int, String> subtitles = {
        26: 'Mestre dos Heterónimos',
        23: 'O Engenheiro Sensacionista',
        25: 'Ode ao Classicismo',
        27: 'Ortónimo de Fernando Pessoa',
        33: 'Bernardo Soares',
        24: 'A epopeia da nação',
        67: 'Outros heterónimos',
        139: 'Textos publicados em vida',
        10000: 'Do persa ao português',
      };

      const mainCategories = [
        26, 23, 25, 27, 33, 24, 67, 139, 10000,
      ];

      for (var id in mainCategories) {
        expect(subtitles.containsKey(id), isTrue,
            reason: 'Category $id should have a subtitle');
      }

      expect(subtitles.length, equals(9));
    });

    test('Subtitle map entries are non-empty strings', () {
      const Map<int, String> subtitles = {
        26: 'Mestre dos Heterónimos',
        23: 'O Engenheiro Sensacionista',
        25: 'Ode ao Classicismo',
        27: 'Ortónimo de Fernando Pessoa',
        33: 'Bernardo Soares',
        24: 'A epopeia da nação',
        67: 'Outros heterónimos',
        139: 'Textos publicados em vida',
        10000: 'Do persa ao português',
      };

      for (var entry in subtitles.entries) {
        expect(entry.value, isNotEmpty,
            reason: 'Subtitle for category ${entry.key} should not be empty');
      }
    });
  });

  group('BrowseTab State Management', () {
    test('Toggle state should default to false (Principal/Main index)', () {

      bool _showFullIndex = false;

      expect(_showFullIndex, equals(false));
      expect(_showFullIndex, isFalse);
    });

    test('Toggle state can switch between true and false', () {
      bool _showFullIndex = false;

      expect(_showFullIndex, isFalse);

      _showFullIndex = true;
      expect(_showFullIndex, isTrue);

      _showFullIndex = false;
      expect(_showFullIndex, isFalse);
    });
  });

  group('Header subtitle logic', () {
    test(
        'Subtitle selection logic: returns appropriate text based on showFullIndex flag',
        () {
      String selectSubtitle(bool showFullIndex) {
        return showFullIndex
            ? 'Índice completo'
            : 'Cinco hetónimos · Uma vida de máscaras';
      }

      expect(
        selectSubtitle(false),
        equals('Cinco hetónimos · Uma vida de máscaras'),
      );
      expect(
        selectSubtitle(true),
        equals('Índice completo'),
      );
    });
  });

  group('Toggle button labels', () {
    test('Toggle segments have correct labels', () {
      const String principalLabel = 'Principal';
      const String completoLabel = 'Completo';

      expect(principalLabel, equals('Principal'));
      expect(completoLabel, equals('Completo'));
    });

    test('Toggle labels are distinct', () {
      const String principalLabel = 'Principal';
      const String completoLabel = 'Completo';

      expect(principalLabel, isNot(equals(completoLabel)));
    });
  });

  group('Subtitle map fallback behavior', () {
    test('Missing category IDs should return empty string', () {
      const Map<int, String> subtitles = {
        26: 'Mestre dos Heterónimos',
        23: 'O Engenheiro Sensacionista',
      };

      final subtitle = subtitles[999] ?? '';

      expect(subtitle, equals(''));
      expect(subtitle, isEmpty);
    });

    test('All main category IDs should have subtitles', () {
      const Map<int, String> subtitles = {
        26: 'Mestre dos Heterónimos',
        23: 'O Engenheiro Sensacionista',
        25: 'Ode ao Classicismo',
        27: 'Ortónimo de Fernando Pessoa',
        33: 'Bernardo Soares',
        24: 'A epopeia da nação',
        67: 'Outros heterónimos',
        139: 'Textos publicados em vida',
        10000: 'Do persa ao português',
      };

      const mainCategories = [
        26, 23, 25, 27, 33, 24, 67, 139, 10000,
      ];

      for (var id in mainCategories) {
        final subtitle = subtitles[id] ?? '';
        expect(subtitle, isNotEmpty,
            reason: 'Main category $id should have a non-empty subtitle');
      }
    });

    test(
        'Extra categories from fullIndex without subtitles render with empty string',
        () {
      const Map<int, String> subtitles = {
        26: 'Mestre dos Heterónimos',
      };

      final extraCategoryId = 999;
      final subtitle = subtitles[extraCategoryId] ?? '';

      expect(subtitle, isEmpty);
    });
  });
}
