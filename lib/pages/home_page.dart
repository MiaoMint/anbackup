import 'package:anbackup/pages/backup_restore/backup_restore.dart';
import 'package:anbackup/pages/miui_backup.dart';
import 'package:anbackup/utils/package_info.dart';
import 'package:anbackup/utils/router.dart';
import 'package:anbackup/widgets/big_button.dart';
import 'package:anbackup/widgets/hero_logo.dart';
import 'package:anbackup/widgets/hero_title.dart';
import 'package:dio/dio.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _checkAdb();
    _checkUpdate();
  }

  _checkAdb() async {
    try {
      debugPrint(await FlutterAdb.version);
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text("未找到 ADB"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextBox(
                  placeholder: "C:\\platform-tools\\adb.exe",
                  onChanged: (value) {
                    FlutterAdb.adbPath = value;
                  },
                )
              ],
            ),
            actions: [
              HyperlinkButton(
                child: const Text("下载 ADB"),
                onPressed: () {
                  launchUrl(Uri.parse(
                      "https://developer.android.com/studio/releases/platform-tools"));
                },
              ),
              FilledButton(
                child: const Text("确定"),
                onPressed: () {
                  _checkAdb();
                  RouterUtil.pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  _checkUpdate({bool showInfoBar = false}) async {
    try {
      const url =
          "https://api.github.com/repos/MiaoMint/anbackup/releases/latest";
      final res = await Dio().get(url);
      final remoteVersion =
          (res.data["tag_name"] as String).replaceFirst('v', '');
      debugPrint('remoteVersion: $remoteVersion');
      if (remoteVersion != packageInfo.version) {
        if (!mounted) {
          return;
        }
        showDialog(
          context: context,
          builder: (context) {
            return ContentDialog(
              title: const Text("发现新版本"),
              content: Text(
                res.data["body"],
                style: const TextStyle(fontSize: 12),
              ),
              actions: [
                HyperlinkButton(
                  child: const Text("关闭"),
                  onPressed: () {
                    RouterUtil.pop();
                  },
                ),
                FilledButton(
                  child: const Text("下载"),
                  onPressed: () {
                    RouterUtil.pop();
                    launchUrl(Uri.parse(res.data["html_url"]));
                  },
                ),
              ],
            );
          },
        );
        return;
      }
      if (showInfoBar && mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text("已是最新版本"),
            content: Text("当前版本：${packageInfo.version}"),
            severity: InfoBarSeverity.success,
          );
        });
      }
    } catch (e) {
      if (showInfoBar && mounted) {
        displayInfoBar(context, builder: (context, close) {
          return InfoBar(
            title: const Text("检查更新失败"),
            content: Text(e.toString()),
            severity: InfoBarSeverity.error,
          );
        });
      }
    }
  }

  _languageSelect(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return ContentDialog(
          title: const Text("选择语言"),
          content: const Text("还没做的"),
          actions: [
            HyperlinkButton(
              child: const Text("关闭"),
              onPressed: () {
                RouterUtil.pop();
              },
            ),
            FilledButton(
              child: const Text("确定"),
              onPressed: () {
                RouterUtil.pop();
              },
            ),
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
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const HeroLogo(
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 20),
                    HeroTitle(
                      "AnBackup",
                      style: FluentTheme.of(context)
                          .typography
                          .titleLarge!
                          .copyWith(
                            color: FluentTheme.of(context)
                                .inactiveColor
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ),
                // 分割线
                Container(
                  width: 1,
                  height: 80,
                  color: FluentTheme.of(context).inactiveColor.withOpacity(0.2),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BigButton(
                      icon: FluentIcons.cloud_download,
                      text: "备份还原",
                      onPressed: () {
                        RouterUtil.push(const BackUpRestorePage());
                      },
                    ),
                    const SizedBox(height: 8),
                    BigButton(
                      icon: FluentIcons.update_restore,
                      text: "MIUI备份还原",
                      onPressed: () {
                        RouterUtil.push(const MiuiRestorePage());
                      },
                    ),
                    // const SizedBox(height: 8),
                    // BigButton(
                    //   icon: FluentIcons.settings,
                    //   text: "设置",
                    //   onPressed: () {
                    //     RouterUtil.push(const MiuiRestorePage());
                    //   },
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                HyperlinkButton(
                  child: Text(
                    "v${packageInfo.version}",
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  onPressed: () {
                    _checkUpdate(showInfoBar: true);
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(FluentIcons.translate),
                  onPressed: () {
                    _languageSelect(context);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
