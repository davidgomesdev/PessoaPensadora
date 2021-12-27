import 'package:equatable/equatable.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

import '../util/generic_extensions.dart';

const _BASE_URL = "http://arquivopessoa.net";
const _INDEX_LINK = "/sidebar";

final _getCategoryLinkRegex = new RegExp("'(/categorias/toggle/.*?)'");

final client = RetryClient(http.Client(),
    retries: 5,
    when: (response) => [500, 502, 503].contains(response.statusCode),
    onRetry: (req, res, count) {
      print("$req -> $res @ $count");
    });

class ArquivoPessoaService {
  String? cookie;

  Future<PessoaIndex> getIndex() async {
    final indexHtml = await _getHtmlDoc(_INDEX_LINK);

    final categories = indexHtml
        .getElementsByClassName("indice")
        .first
        .children
        .map((category) {
      final subcategoryLink = _getCategoryLink(category);
      return PessoaCategory._internal(subcategoryLink,
          title: category.querySelector(".titulo-categoria")!.text, texts: []);
    });

    return PessoaIndex(categories: categories);
  }

  Future<PessoaCategory> fetchCategory(PessoaCategory category) async {
    final link = category._link;

    if (link == null)
      return Future.error(Exception("No URL for ${category.title}"));

    final html = (await _getHtmlDoc(link)).documentElement;

    if (html == null) return Future.error("No html on ${category.title}");

    return _parseCategory(link, html);
  }

  Future<PessoaText> fetchText(PessoaText text) async {
    final link = text._link;

    if (link == null)
      return Future.error(Exception("No URL for ${text.title}"));

    final html = await _getHtmlDoc(link);

    final title = html.getElementsByClassName("titulo-texto").first.text;
    final author = html.getElementsByClassName("autor").first.text;
    final content = html.firstWhereOrNull<String>(
        (e, param) => e.getElementsByClassName(param).firstOrNull?.text,
        ["texto-poesia", "texto-prosa"]);

    if (content == null)
      throw Exception("No text content in HTML $_BASE_URL$link");

    return PessoaText._internal(link,
        title: title, content: content, author: author);
  }

  Future<Document> _getHtmlDoc(String link) async {
    final response = await client.get(Uri.parse("$_BASE_URL$link"));
    final html = response.bodyBytes;

    return parse(html);
  }

  Future<PessoaCategory> _parseCategory(String link, Element html) async {
    final title = html.querySelector(".titulo-categoria")!.text;
    final subcategoriesHtml = html.getElementsByClassName("categoria");

    final subCategories = subcategoriesHtml.map((cat) {
      final subcategoryLink = _getCategoryLink(cat);

      return PessoaCategory._internal(subcategoryLink,
          title: cat.getElementsByClassName("titulo-categoria").first.text,
          texts: []);
    });
    final texts = html
        .querySelectorAll("a.titulo-texto")
        .map((e) => PessoaText._internal(e.attributes["href"]!, title: e.text))
        .toList();

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
