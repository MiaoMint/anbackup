import 'package:anbackup/widgets/hero_header.dart';
import 'package:fluent_ui/fluent_ui.dart';

class MiuiRestorePage extends StatelessWidget {
  const MiuiRestorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: HeroHeader("MIUI 备份包还原"),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "(っ °Д °;)っ",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text("前面的内容以后再来探索吧！~"),
              ],
            ),
          )
        ],
      ),
    );
  }
}
