import 'package:anbackup/pages/backup_restore/backup_or_restore.dart';
import 'package:anbackup/utils/router.dart';
import 'package:anbackup/widgets/device_select.dart';
import 'package:anbackup/widgets/hero_header.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';

class BackUpRestorePage extends StatefulWidget {
  const BackUpRestorePage({Key? key}) : super(key: key);

  @override
  State<BackUpRestorePage> createState() => _BackUpRestorePageState();
}

class _BackUpRestorePageState extends State<BackUpRestorePage> {
  // 无线连接
  _wireless() {
    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text("通过 无限调试 连接"),
          content: TextBox(
            placeholder: "请输入 IP 地址，按下回车键开始连接",
            onSubmitted: (value) async {
              try {
                await FlutterAdb.connect(value);
                RouterUtil.pop();
              } catch (e) {
                displayInfoBar(
                  context,
                  builder: (context, close) {
                    return const InfoBar(
                      title: Text("连接失败"),
                      content: Text("请检查 IP 地址是否正确，以及设备是否已经开启 USB 调试模式。"),
                      severity: InfoBarSeverity.error,
                    );
                  },
                );
              }
            },
          ),
          actions: [
            FilledButton(
                child: const Text("关闭"),
                onPressed: () {
                  RouterUtil.pop();
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: HeroHeader(
              "备份还原",
              trailing: Row(
                children: [
                  IconButton(
                    icon: const Icon(FluentIcons.link),
                    onPressed: () {
                      _wireless();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DeviceSelect(
              onSelected: (device) {
                RouterUtil.push(
                  BackupOrRestorePage(device: device),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
