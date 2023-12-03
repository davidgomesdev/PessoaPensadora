import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:pessoa_bonito/dto/box/box_person_text.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/service/text_store.dart';

part 'saved_text.g.dart';

@HiveType(typeId: 1)
class SavedText {
  @HiveField(10)
  final int id;

  SavedText(this.id);

  factory SavedText.fromText(PessoaText text) => SavedText(text.id);

  BoxPessoaText toModel() {
    final TextStoreService storeService = Get.find();
    return storeService.texts[id]!;
  }
}
