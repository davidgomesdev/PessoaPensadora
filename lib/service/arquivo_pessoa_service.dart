import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:pessoa_bonito/model/pessoa_category.dart';
import 'package:pessoa_bonito/model/pessoa_text.dart';
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

  Future<PessoaCategory> getIndex() async {
    final indexHtml = await _getHtmlDoc(_INDEX_LINK);

    log.i("Retrieved index HTML");

    final categories = indexHtml
        .getElementsByClassName("indice")
        .first
        .children
        .map((category) {
      final categoryLink = _getCategoryLink(category);
      final title = category.querySelector(".titulo-categoria")!.text;

      return PessoaCategory.preview(categoryLink, title: title);
    });

    log.i("Parsed index HTML");

    return PessoaCategory.index(_INDEX_LINK, subcategories: categories);
  }

  Future<PessoaCategory> fetchCategory(
      PessoaCategory category, PessoaCategory? previousCategory) async {
    final link = category.link;

    log.d('Fetching "$link"');

    final html = (await _getHtmlDoc(link)).documentElement;

    log.i('Retrieved category HTML (${category.title})');

    if (html == null) return Future.error("No html on ${category.title}");

    final fetchedCategory = _parseCategory(link, html, previousCategory);

    log.i('Finished parsing category ("${category.title}")');

    return fetchedCategory;
  }

  Future<PessoaText> fetchText(PessoaText text, PessoaCategory category) async {
    final link = text.link;

    if (link == null)
      return Future.error(Exception("No URL for ${text.title}"));

    final html = await _getHtmlDoc(link);

    log.i("Retrieved text HTML");

    final title = html.getElementsByClassName("titulo-texto").first.text.trim();
    final author = html.getElementsByClassName("autor").first.text;

    // Used to remove the title from the text
    // because in some it's just redundant (although on others it is part
    // of the text)
    final titleRegex = title
        .replaceAll(' ', ' ')
        .extractLetters()
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();

    final content = html
        .firstWhereOrNull(
          (e, param) => e.getElementsByClassName(param).firstOrNull,
          ["texto-poesia", "texto-prosa"],
        )
        ?.children
        .map((paragraph) {
          if (paragraph.children.isNotEmpty) {
            return paragraph.children.map((e) {
              return e.text.trim();
            }).reduce((value, element) => "$value $element");
          }
          return paragraph.text;
        })
        .reduce((value, element) => "$value\n$element")
        .replaceAll(RegExp(r' {1,}'), ' ')
        .replaceAll("\n\n\n", "\n\n")
        .replaceAll(RegExp('^' + titleRegex + r'(?=\n *\n)'), '')
        .trim();

    return PessoaText(link, category,
        title: title, content: content, author: author);
  }

  Future<Document> _getHtmlDoc(String link) async {
    final response = await client.get(Uri.parse("$_BASE_URL$link"));
    final html = response.bodyBytes;

    return parse(html);
  }

  Future<PessoaCategory> _parseCategory(
      String link, Element html, PessoaCategory? previousCategory) async {
    final title = html.querySelector(".titulo-categoria")!.text.trim();
    final subcategoriesHtml = html.getElementsByClassName("categoria");

    log.d('Parsing "$title"');

    final subcategories = subcategoriesHtml.map((cat) {
      final title =
          cat.getElementsByClassName("titulo-categoria").first.text.trim();
      final link = _getCategoryLink(cat);

      return PessoaCategoryBuilder.preview(link, title: title);
    });

    log.i("Parsed subcategories");

    final texts = html
        .querySelectorAll("a.titulo-texto")
        .map((e) =>
            PessoaTextBuilder(e.attributes["href"]!, title: e.text.trim()))
        .toList();

    log.i("Parsed texts");

    log.i('Finished parsing category ("$title")');

    return PessoaCategory.full(link,
        title: title,
        textBuilders: texts,
        subcategoryBuilders: subcategories,
        previousCategory: previousCategory);
  }

  String _getCategoryLink(Element html) {
    final categoryLink = _getCategoryLinkRegex
        .firstMatch(html.querySelector(".ctrl-opener")!.attributes["onclick"]!)
        ?.group(1);

    if (categoryLink == null) throw Exception("No category link in HTML!");

    return categoryLink;
  }
}

extension RegexExtension on String {
  String extractLetters() =>
      replaceAll(RegExp(r'[^A-Za-záàâãéèêíïóôõöúçñÁÀÂÃÉÈÍÏÓÔÕÖÚÇÑ ]+'), '');
}
