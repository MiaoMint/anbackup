import 'package:anbackup/widgets/hero_logo.dart';
import 'package:anbackup/widgets/hero_title.dart';
import 'package:fluent_ui/fluent_ui.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader(
    this.title, {
    Key? key,
    this.trailing,
  }) : super(key: key);
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Row(
              children: [
                const Icon(
                  FluentIcons.back,
                  size: 15,
                ),
                const SizedBox(width: 16),
                const HeroLogo(
                  width: 35,
                  height: 35,
                ),
                const SizedBox(width: 10),
                HeroTitle(
                  title,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}
