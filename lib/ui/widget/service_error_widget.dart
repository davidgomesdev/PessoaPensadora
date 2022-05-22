import 'package:flutter/widgets.dart';
import 'package:pessoa_bonito/messages.dart';
import 'package:pessoa_bonito/util/logger_factory.dart';
import 'package:pessoa_bonito/util/network_utils.dart';

class ServiceErrorWidget extends StatelessWidget {
  final Object error;

  const ServiceErrorWidget(this.error, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (error is NoInternetException) {
      return const Text(noInternet);
    } else if (error is SourceNotAccessibleException) {
      return const Text(
        arquivoPessoaNotAccessible,
        textAlign: TextAlign.center,
      );
    }
    log.e("Error building drawer", error);

    return const Text(unexpectedException);
  }
}
