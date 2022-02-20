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

    log.i("Retrieved index HTML");

    final categories = indexHtml
        .getElementsByClassName("indice")
        .first
        .children
        .map((category) {
      final subcategoryLink = _getCategoryLink(category);
      final title = category.querySelector(".titulo-categoria")!.text;

      return PessoaCategory._internal(subcategoryLink,
          title: title, texts: [], isPreview: true);
    });

    log.i("Parsed index HTML");

    return PessoaIndex(categories: categories);
  }

  Future<PessoaCategory> fetchCategory(
      PessoaCategory category, PessoaCategory? previousCategory) async {
    final link = category._link;

    if (link == null)
      return Future.error(Exception("No URL for ${category.title}"));

    log.d('Fetching "$link"');

    final html = (await _getHtmlDoc(link)).documentElement;

    log.i('Retrieved category HTML (${category.title})');

    if (html == null) return Future.error("No html on ${category.title}");

    final fetchedCategory = _parseCategory(link, html);

    log.i('Finished parsing category ("${category.title}")');

    return fetchedCategory.then((builder) => builder.build(previousCategory));
  }

  Future<PessoaText> fetchText(PessoaText text, PessoaCategory category) async {
    final link = text._link;

    if (link == null)
      return Future.error(Exception("No URL for ${text.title}"));

    final html = await _getHtmlDoc(link);

    log.i("Retrieved text HTML");

    final title = html.getElementsByClassName("titulo-texto").first.text.trim();
    final author = html.getElementsByClassName("autor").first.text;
    var content = html
        .firstWhereOrNull<String>(
          (e, param) => e.getElementsByClassName(param).firstOrNull?.text,
          ["texto-poesia", "texto-prosa"],
        )
        ?._removeRedundantText()
        .replaceFirst(RegExp('^$title *\n'), '');

    return PessoaText._internal(link, category,
        title: title, content: content, author: author);
  }

  Future<Document> _getHtmlDoc(String link) async {
    final response = await client.get(Uri.parse("$_BASE_URL$link"));
    final html = response.bodyBytes;

    return parse(html);
  }

  Future<PessoaCategoryBuilder> _parseCategory(
      String link, Element html) async {
    final title = html.querySelector(".titulo-categoria")!.text.trim();
    final subcategoriesHtml = html.getElementsByClassName("categoria");

    log.d('Parsing "$title"');

    final subCategories = subcategoriesHtml.map((cat) {
      final title =
          cat.getElementsByClassName("titulo-categoria").first.text.trim();
      final link = _getCategoryLink(cat);

      return PessoaCategoryBuilder(link, title: title, textBuilders: []);
    });

    log.i("Parsed subcategories");

    final texts = html
        .querySelectorAll("a.titulo-texto")
        .map((e) => PessoaTextBuilder(e.attributes["href"]!, title: e.text))
        .toList();

    log.i("Parsed texts");

    log.i('Finished parsing category ("$title")');

    return PessoaCategoryBuilder(link,
        title: title, textBuilders: texts, subcategories: subCategories);
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
  final PessoaCategory? previousCategory;
  late Iterable<PessoaText> texts;
  late Iterable<PessoaCategory>? subcategories;
  final bool isPreview;

  PessoaCategory._(String? _link,
      {required String title,
      required this.isPreview,
      this.previousCategory,
      required this.texts,
      this.subcategories})
      : _link = _link,
        title = title.trim();

  PessoaCategory._internal(String? _link,
      {required String title,
      this.isPreview = false,
      this.previousCategory,
      required Iterable<PessoaTextBuilder> texts,
      Iterable<PessoaCategoryBuilder>? subcategories})
      : _link = _link,
        title = title.trim() {
    this.texts = texts.map((builder) => builder.build(this));
    this.subcategories =
        subcategories?.map((builder) => builder.build(this, isPreview: true));
  }

  @override
  List<Object?> get props => [_link, title];
}

class PessoaCategoryBuilder {
  final String? _link;
  final String title;
  Iterable<PessoaTextBuilder> textBuilders;
  final Iterable<PessoaCategoryBuilder>? subcategories;

  PessoaCategoryBuilder(String? _link,
      {required String title, required this.textBuilders, this.subcategories})
      : _link = _link,
        title = title.trim();

  PessoaCategory build(PessoaCategory? previousCategory,
          {bool isPreview = false}) =>
      PessoaCategory._internal(_link,
          title: title,
          texts: textBuilders,
          previousCategory: previousCategory,
          subcategories: subcategories,
          isPreview: isPreview);
}

class PessoaIndex extends PessoaCategory with EquatableMixin {
  PessoaIndex({required Iterable<PessoaCategory> categories})
      : super._(_INDEX_LINK,
            title: "Índice",
            texts: [],
            subcategories: categories,
            isPreview: false);

  @override
  List<Object?> get props => super.props;
}

class PessoaText with EquatableMixin {
  final PessoaCategory category;
  final String? _link;
  final String title;
  final String? content;
  final String? author;

  PessoaText._internal(this._link, this.category,
      {required String title, String? content, String? author})
      : title = title.trim(),
        content = content?.trim(),
        author = author?.trim();

  PessoaText(PessoaCategory category,
      {required String title,
      required String? content,
      required String? author})
      : this._internal(null, category,
            title: title, content: content, author: author);

  @override
  List<Object?> get props => [_link, title];
}

class PessoaTextBuilder {
  final String? _link;
  final String title;
  final String? content;
  final String? author;

  PessoaTextBuilder(this._link,
      {required String title, String? content, String? author})
      : title = title.trim(),
        content = content?.trim(),
        author = author?.trim();

  PessoaText build(PessoaCategory category) =>
      PessoaText._internal(this._link, category,
          title: title, content: content, author: author);
}

extension StringRegex on String {
  String _removeRedundantText() => replaceAll(' ', ' ')
      .replaceAll(RegExp(r'^\n*(?=[^\n])'), '')
      .replaceAll(RegExp(r'^(?: .*\n*)+'), '')
      .replaceAll(RegExp(r'$\n\n +', multiLine: true), '\n\n')
      .replaceAll(RegExp(r'$\n {2,}$', multiLine: true), ' ')
      .replaceAll(RegExp(r'^\n*(?: .*\n\n?)+(?=\w)'), '')
      .replaceAll(RegExp(r'\n{3,}', multiLine: true), '\n\n')
      .replaceAll(RegExp(r' {2,}\n +', multiLine: true), ' ')
      .trim();
}
