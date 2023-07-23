import 'package:hive/hive.dart';

part 'box_person_category.g.dart';

@HiveType(typeId: 11)
class BoxPersonCategory {
  @HiveField(10)
  final int id;
  @HiveField(20)
  final String title;
  @HiveField(30)
  final int parentCategory;
  @HiveField(40)
  final List<int> subcategories;

  BoxPersonCategory(
    this.id,
    this.title,
    this.parentCategory,
    this.subcategories,
  );
}
