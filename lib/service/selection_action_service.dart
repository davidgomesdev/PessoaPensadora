import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectionActionService {

  void defineWord(String word) {
    launchUrl(Uri.https("dicionario.priberam.org", '/$word'));
  }
  
  void searchOnline(String text) {
    launchUrl(Uri.https("google.pt", '/search', {'q': text}));
  }

  void shareQuote(String text, String author) {
    SharePlus.instance.share(ShareParams(text: '"$text" - $author'));
  }

  void shareText(String text, String author) {
    SharePlus.instance.share(ShareParams(text: """
$text

            $author
    """.trim()));
  }
}