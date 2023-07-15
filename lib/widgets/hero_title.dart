import 'package:fluent_ui/fluent_ui.dart';

class HeroTitle extends StatelessWidget {
  const HeroTitle(
    this.text, {
    Key? key,
    this.style,
  }) : super(key: key);
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'title',
      child: Text(text, style: style),
    );
  }
}
