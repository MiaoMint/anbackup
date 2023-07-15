import 'package:anbackup/main.dart';
import 'package:fluent_ui/fluent_ui.dart';

class RouterUtil {
  static final context = rootNavigatorKey.currentContext!;

  static push(Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: page,
          );
        },
      ),
    );
  }

  static pop() {
    Navigator.of(context).pop();
  }
}
