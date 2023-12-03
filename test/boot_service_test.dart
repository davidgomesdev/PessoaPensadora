@GenerateNiceMocks([MockSpec<AssetBundle>()])
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pessoa_bonito/service/text_store.dart';
import 'package:test/test.dart';

import 'boot_service_test.mocks.dart';

void main() {
  late String exampleJson;

  setUp(() {
    exampleJson = File('test/assets/example.json').readAsStringSync();
  });

  test('Passes', () async {
    final assetBundleMock = MockAssetBundle();

    when(assetBundleMock.loadString(any)).thenAnswer((_) async => exampleJson);

    final service = await TextStoreService.initialize(assetBundleMock);
    final index = service.index;

    expect(index.subcategories, hasLength(4));
    expect(index.texts, isEmpty);

    final emptyCategory = index.subcategories[0];
    final categoryWithSubcategories = index.subcategories[1];
    final categoryWithTexts = index.subcategories[2];
    final categoryWithSubcategoriesAndTexts = index.subcategories[3];

    expect(emptyCategory.subcategories, isEmpty);
    expect(emptyCategory.texts, isEmpty);

    expect(categoryWithSubcategories.subcategories, hasLength(1));
    expect(categoryWithSubcategories.subcategories.first.id, equals(10));
    expect(categoryWithSubcategories.texts, isEmpty);

    expect(categoryWithTexts.subcategories, isEmpty);
    expect(categoryWithTexts.texts, hasLength(2));
    expect(categoryWithTexts.texts.first.id, equals(9));
    expect(categoryWithTexts.texts[1].id, equals(1));

    expect(
      categoryWithSubcategoriesAndTexts.subcategories,
      hasLength(1),
    );
    expect(
        categoryWithSubcategoriesAndTexts.subcategories.first.id, equals(10));

    expect(categoryWithSubcategoriesAndTexts.texts, hasLength(2));
    expect(categoryWithSubcategoriesAndTexts.texts.first.id, equals(1234));
    expect(categoryWithSubcategoriesAndTexts.texts[1].id, equals(9));
  });
}
