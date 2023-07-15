import 'package:fluent_ui/fluent_ui.dart';

class BigButton extends StatelessWidget {
  const BigButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);
  final IconData icon;
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: 270,
        height: 60,
        child: Button(
          onPressed: onPressed,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Icon(
                icon,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              const Icon(
                FluentIcons.chevron_right,
                size: 15,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
