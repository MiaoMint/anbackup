import 'package:anbackup/model/backup_config.dart';
import 'package:anbackup/service/restore.dart';
import 'package:anbackup/widgets/app_progress_lndicator.dart';
import 'package:anbackup/widgets/hero_title.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';

class StartRestore extends StatefulWidget {
  const StartRestore({
    Key? key,
    required this.device,
    required this.backupConfig,
    required this.basePath,
  }) : super(key: key);
  final Device device;
  final String basePath;
  final BackupConfig backupConfig;

  @override
  State<StartRestore> createState() => _StartRestoreState();
}

class _StartRestoreState extends State<StartRestore> {
  late String deviceName = "${widget.device.brand} ${widget.device.marketName}";
  late int num = widget.backupConfig.package.length;
  bool isDone = false;
  bool isData = false;
  late Restore restore;
  int numIndex = 0;
  String cuurentPackage = "";
  bool _skipData = false;

  @override
  void initState() {
    _startRestore();
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("dispose");
    restore.dispose();
    super.dispose();
  }

  _startRestore() async {
    restore = Restore(
      device: widget.device,
      basePath: widget.basePath,
    );

    for (var package in widget.backupConfig.package.entries) {
      numIndex++;
      cuurentPackage = package.key;
      try {
        if (package.value.apk) {
          isData = false;
          _update();
          await restore.restoreApk(package.value);
        }
        if (package.value.data && !_skipData) {
          isData = true;
          _update();
          try {
            // 切换 root
            await widget.device.root();
          } catch (e) {
            debugPrint(e.toString());
            if (mounted) {
              displayInfoBar(context, builder: (context, close) {
                return InfoBar(
                  title: Text("切换 root 失败,将不会恢复应用数据,请关闭 Magisk Hide 后重试; $e"),
                  severity: InfoBarSeverity.error,
                );
              });
            }
            _skipData = true;
          }
          await restore.restoreData(package.key);
        }
      } catch (e) {
        debugPrint(e.toString());
        continue;
      }
    }
    isDone = true;
    _update();
  }

  _update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HeroTitle(
            isDone ? "恢复 $deviceName 完成" : "正在恢复 $deviceName 的数据",
            style: FluentTheme.of(context).typography.title,
          ),
          const SizedBox(height: 30),
          if (isDone)
            const Icon(
              FluentIcons.check_mark,
              size: 100,
            )
          else
            AppProgressIndicator(
              package: cuurentPackage,
              isData: isData,
            ),
          const SizedBox(height: 30),
          ProgressBar(
            value: isDone ? 100 : numIndex / num * 100,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "第 $numIndex 个 $cuurentPackage , 共 $num 个应用",
              ),
            ],
          ),
          const SizedBox(height: 30),
          Button(
            child: Text(isDone ? "完成" : "取消"),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
    );
  }
}
