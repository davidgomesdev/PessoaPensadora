import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';

import '../util/generic_extensions.dart';

const _baseUrl = "http://arquivopessoa.net";
const _indexLink = "/sidebar";

final _getCategoryLinkRegex = RegExp("'(/categorias/toggle/.*?)'");

final client = RetryClient(http.Client(),
    retries: 5,
    when: (response) => [500, 502, 503].contains(response.statusCode));

class ArquivoPessoaService {
  String? cookie;

  Future<PessoaCategory> getIndex() async {
    final index = PessoaCategory.index(_indexLink);
    final indexHtml = await _getHtmlDoc(_indexLink);

    log.i("Retrieved index HTML");

    final categories = indexHtml
        .getElementsByClassName("indice")
        .first
        .children
        .map((cat) => _parsePreviewCategory(index, cat));

    log.i("Parsed index HTML");

    return index..setSubcategories(categories.toList());
  }

  Future<PessoaCategory> fetchCategory(
      PessoaCategory category, PessoaCategory? previousCategory) async {
    final link = category.link;

    log.d('Fetching "$link"');

    final html = (await _getHtmlDoc(link)).documentElement;

    log.i('Retrieved category HTML (${category.title})');

    if (html == null) return Future.error("No html on ${category.title}");

    final fetchedCategory = _parseFullCategory(link, html, previousCategory);

    log.i('Finished parsing category ("${category.title}")');

    return fetchedCategory;
  }

  Future<PessoaText> fetchText(PessoaText text, PessoaCategory category) async {
    final link = text.link;
    final html = await _getHtmlDoc(link);

    log.i("Retrieved text HTML");

    final title = html.getElementsByClassName("titulo-texto").first.text.trim();
    final author = html.getElementsByClassName("autor").first.text;

    final contentHtml = html.firstMultiWhere(
          (e, param) => e.getElementsByClassName(param).firstOrNull,
          ["texto-poesia", "texto-prosa"],
        )?.children ??
        List.empty();
    final content = getNestedContent(contentHtml).removeTitle();

    log.d("Text after processed:\n\n$content");

    return PessoaText.full(link, category, text.id,
        title: title, content: content, author: author);
  }

  String getNestedContent(List<Element> node) {
    return node.map((paragraph) {
      if (paragraph.children.isNotEmpty) {
        return paragraph.children.map((e) {
          return e.text.trim();
        }).reduce((value, element) => "$value $element");
      }
      return paragraph.text.trim();
    }).reduce((value, element) => "$value\n$element");
  }

  Future<Document> _getHtmlDoc(String link) async {
    final response = await client.get(Uri.parse("$_baseUrl$link"));
    final html = response.bodyBytes;

    return parse(html);
  }

  String _getCategoryLink(Element html) {
    final categoryLink = _getCategoryLinkRegex
        .firstMatch(html.querySelector(".ctrl-opener")!.attributes["onclick"]!)
        ?.group(1);

    if (categoryLink == null) throw Exception("No category link in HTML!");

    return categoryLink;
  }

  Future<PessoaCategory> _parseFullCategory(
      String link, Element html, PessoaCategory? previousCategory) async {
    final title = html.querySelector(".titulo-categoria")!.text.trim();
    final subcategoriesHtml = html.getElementsByClassName("categoria");

    final category = PessoaCategory.full(link,
        title: title, parentCategory: previousCategory);

    log.d('Parsing "$title"');

    final subcategories = subcategoriesHtml
        .map((html) => _parsePreviewCategory(category, html))
        .toList();
    log.i("Parsed subcategories");

    int id = 0;
    final texts = html
        .querySelectorAll("a.titulo-texto")
        .map((e) => PessoaText.preview(e.attributes["href"]!, category, id++,
            title: e.text.trim()))
        .toList();
    log.i("Parsed texts");

    log.i('Finished parsing category ("$title")');

    return category
      ..setSubcategories(subcategories)
      ..setTexts(texts);
  }

  PessoaCategory _parsePreviewCategory(PessoaCategory parent, Element html) {
    final categoryLink = _getCategoryLink(html);
    final title = html.querySelector(".titulo-categoria")!.text;

    return PessoaCategory.preview(categoryLink,
        title: title, parentCategory: parent);
  }
}

extension RegexExtension on String {
  String removeTitle() => replaceAll(
      RegExp(r'(?<!.\n)(?:^.+\n\n)+(?=.+\n\n|.+\n)', multiLine: true), '');
}
