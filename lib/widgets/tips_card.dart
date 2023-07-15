import 'package:fluent_ui/fluent_ui.dart';

class TipsCard extends StatelessWidget {
  const TipsCard({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FluentTheme.of(context).cardColor,
        border: Border(
          left:
              BorderSide(color: FluentTheme.of(context).accentColor, width: 3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(FluentIcons.info),
          const SizedBox(width: 10),
          child,
        ],
      ),
    );
  }
}
