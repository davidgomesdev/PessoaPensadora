import 'package:get/get_navigation/src/root/internacionalization.dart';

class Labels extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'pt': {
          // HomeScreen
          'index': 'Índice',
          'main_menu_subtitle':
              'Textos de Fernando Pessoa, provenientes de Arquivo Pessoa',
          'main_menu_subtitle_note': '(sem qualquer afiliação)',
          'view_on_arquivo_pessoa': 'Ver no Arquivo Pessoa',
          /// Also in history screen
          'history': 'Histórico',
          // TextReader Context Menu
          'define': '📖 Definir',
          'search': '🔍 Pesquisar',
          'share': '📤 Partilhar',
          // SavedTextsScreen
          'delete': 'Apagar',
          'cancel': 'Cancelar',
          'bookmark': 'Guardar',
          'bookmarked_texts': 'Textos marcados',
          'removed_from_bookmarks': 'Removido dos textos marcados',
          'collapse_all': 'Recolher todos',
          'expand_all': 'Expandir todos',
          // Bug Report
          'report_a_problem': 'Reportar problema',
          'report_a_problem_desc':
              'É necessário guardares o registo para reportar problemas.',
          'choose_where_to_save':
              'Escolhe onde pretendes guardar o registo do problema.\nDepois anexa-o no e-mail. ⚠️',
          'report_a_problem_email_subject': 'RESUME O PROBLEMA AQUI',
          'report_a_problem_email_body': 'Descreve aqui detalhadamente o problema.\n\n'
              'Escreve como aconteceu.\n\n'
              'E inclui screenshots ou '
              'um video mostrando o que fizeste para o problema surgir, '
              'para que eu consiga reproduzir do meu lado.\n\n'
              '⚠️ Anexa também o ficheiro que guardaste (o nome começa por "0-Pessoa-Pensadora-Registo-de-Problemas").\n\n'
              'Dica: depois experimenta fechar a app e voltar a abrir para ver se resolve.',
          'ok': 'Ok',
          // Drawer
          'back': 'Voltar',
          'full_reading_mode': 'Leitura integral',
          'main_reading_mode': 'Leitura principal',
          /// Filter
          'search_read_filter_all': 'Todos',
          'search_read_filter_read': 'Apenas lidos',
          'search_read_filter_unread': 'Apenas não lidos',
        },
        'en': {
          // HomeScreen
          'index': 'Index',
          'main_menu_subtitle': "Fernando Pessoa's texts, sourced from Arquivo Pessoa",
          'main_menu_subtitle_note': '(without affiliation)',
          'view_on_arquivo_pessoa': 'View on Arquivo Pessoa',
          /// Also in history screen
          'history': 'History',
          // TextReader Context Menu
          'define': '📖 Define',
          'search': '🔍 Search',
          'share': '📤 Share',
          // SavedTextsScreen
          'delete': 'Delete',
          'cancel': 'Cancel',
          'bookmark': 'Bookmark',
          'bookmarked_texts': 'Bookmarked texts',
          'removed_from_bookmarks': 'Removed from bookmarks',
          'collapse_all': 'Collapse all',
          'expand_all': 'Expand all',
          // Bug Report
          'report_a_problem': 'Report a problem',
          'report_a_problem_desc': 'You must save the log to report problems.',
          'choose_where_to_save': 'Choose where you want to save the problem log.\nThen attach it to the email. ⚠️',
          'report_a_problem_email_subject': 'SUMMARIZE THE PROBLEM HERE',
          'report_a_problem_email_body': 'Describe the problem in detail here.\n\n'
              'Explain how it happened.\n\n'
              'Include screenshots or a video showing what you did for the problem to appear, so I can reproduce it on my side.\n\n'
              '⚠️ Also attach the file you saved (its name starts with "0-Pessoa-Pensadora-Registo-de-Problemas").\n\n'
              'Tip: try closing and reopening the app to see if it works again.',
          'ok': 'Ok',
          // Drawer
          'back': 'Back',
          'full_reading_mode': 'Full reading',
          'main_reading_mode': 'Main reading',
          /// Filter
          'search_read_filter_all': 'All',
          'search_read_filter_read': 'Only read',
          'search_read_filter_unread': 'Only unread',
        }
      };
}
