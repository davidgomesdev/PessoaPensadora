import 'package:equatable/equatable.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

import '../util/generic_extensions.dart';

const _BASE_URL = "http://arquivopessoa.net";
const _INDEX_LINK = "/sidebar";

final _getCategoryLinkRegex = new RegExp("'(/categorias/toggle/.*?)'");

final client = RetryClient(http.Client(),
    retries: 5,
    when: (response) => [500, 502, 503].contains(response.statusCode));

class ArquivoPessoaService {
  String? cookie;

  Future<PessoaIndex> getIndex() async {
    final indexHtml = await _getHtmlDoc(_INDEX_LINK);

    logger.i("Retrieved index HTML");

    final categories = indexHtml
        .getElementsByClassName("indice")
        .first
        .children
        .map((category) {
      final subcategoryLink = _getCategoryLink(category);
      return PessoaCategory._internal(subcategoryLink,
          title: category.querySelector(".titulo-categoria")!.text, texts: []);
    });

    logger.i("Parsed index HTML");

    return PessoaIndex(categories: categories);
  }

  Future<PessoaCategory> fetchCategory(PessoaCategory category) async {
    final link = category._link;

    if (link == null)
      return Future.error(Exception("No URL for ${category.title}"));

    logger.d('Fetching "$link"');

    final html = (await _getHtmlDoc(link)).documentElement;

    logger.i('Retrieved category HTML (${category.title})');

    if (html == null) return Future.error("No html on ${category.title}");

    final fetchedCategory = _parseCategory(link, html);

    logger.i('Finished parsing category ("${category.title}")');

    return fetchedCategory;
  }

  Future<PessoaText> fetchText(PessoaText text) async {
    final link = text._link;

    if (link == null)
      return Future.error(Exception("No URL for ${text.title}"));

    final html = await _getHtmlDoc(link);

    logger.i("Retrieved text HTML");

    final title = html.getElementsByClassName("titulo-texto").first.text.trim();
    final author = html.getElementsByClassName("autor").first.text;
    final content = html.firstWhereOrNull<String>(
        (e, param) => e.getElementsByClassName(param).firstOrNull?.text,
        ["texto-poesia", "texto-prosa"]);

    logger.i('Parsed text "$title"');

    return PessoaText._internal(link,
        title: title, content: content, author: author);
  }

  Future<Document> _getHtmlDoc(String link) async {
    final response = await client.get(Uri.parse("$_BASE_URL$link"));
    final html = response.bodyBytes;

    return parse(html);
  }

  Future<PessoaCategory> _parseCategory(String link, Element html) async {
    final title = html.querySelector(".titulo-categoria")!.text.trim();
    final subcategoriesHtml = html.getElementsByClassName("categoria");

    logger.d('Parsing "$title"');

    final subCategories = subcategoriesHtml.map((cat) {
      final title =
          cat.getElementsByClassName("titulo-categoria").first.text.trim();
      final link = _getCategoryLink(cat);

      return PessoaCategory._internal(link, title: title, texts: []);
    });

    logger.i("Parsed subcategories");

    final texts = html
        .querySelectorAll("a.titulo-texto")
        .map((e) => PessoaText._internal(e.attributes["href"]!, title: e.text))
        .toList();

    logger.i("Parsed texts");

    logger.i('Finished parsing category ("$title")');

    return PessoaCategory._internal(link,
        title: title, texts: texts, subcategories: subCategories);
  }

  String _getCategoryLink(Element html) {
    final categoryLink = _getCategoryLinkRegex
        .firstMatch(html.querySelector(".ctrl-opener")!.attributes["onclick"]!)
        ?.group(1);

    if (categoryLink == null) throw Exception("No category link in HTML!");

    return categoryLink;
  }
}

class PessoaCategory with EquatableMixin {
  final String? _link;
  final String title;
  final Iterable<PessoaText> texts;
  final Iterable<PessoaCategory>? subcategories;

  PessoaCategory._internal(String? _link,
      {required String title, required this.texts, this.subcategories})
      : _link = _link,
        title = title.trim();

  PessoaCategory(
      {required String title,
      required Iterable<PessoaText> texts,
      Iterable<PessoaCategory>? subcategories})
      : this._internal(null,
            title: title, texts: texts, subcategories: subcategories);

  @override
  List<Object?> get props => [_link, title];
}

class PessoaIndex extends PessoaCategory with EquatableMixin {
  PessoaIndex({required Iterable<PessoaCategory> categories})
      : super._internal(_INDEX_LINK,
            title: "Índice", texts: [], subcategories: categories);

  @override
  List<Object?> get props => super.props;
}

class PessoaText with EquatableMixin {
  final String? _link;
  final String title;
  final String? content;
  final String? author;

  PessoaText._internal(this._link,
      {required String title, String? content, String? author})
      : title = title.trim(),
        content = content?.trim(),
        author = author?.trim();

  PessoaText(
      {required String title,
      required String? content,
      required String? author})
      : this._internal(null, title: title, content: content, author: author);

  @override
  List<Object?> get props => [_link, title];
}
