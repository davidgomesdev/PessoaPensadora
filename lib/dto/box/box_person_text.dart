import 'package:hive/hive.dart';

part 'box_person_text.g.dart';

@HiveType(typeId: 10)
class BoxPersonText {
  @HiveField(10)
  final int id;
  @HiveField(20)
  final int categoryId;
  @HiveField(30)
  final String title;
  @HiveField(40)
  String content;
  @HiveField(50)
  final String author;

  BoxPersonText(
    this.id,
    this.categoryId,
    this.title,
    this.content,
    this.author,
  );
}
