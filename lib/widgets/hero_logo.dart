import 'package:fluent_ui/fluent_ui.dart';

class HeroLogo extends StatelessWidget {
  const HeroLogo({
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: FluentTheme.of(context).inactiveColor.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.asset(
          "assets/icon/logo.png",
          width: width,
          height: height,
        ),
      ),
    );
  }
}
