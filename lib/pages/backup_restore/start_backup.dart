import 'package:anbackup/model/backup_config.dart';
import 'package:anbackup/pages/home_page.dart';
import 'package:anbackup/service/backup.dart';
import 'package:anbackup/utils/router.dart';
import 'package:anbackup/widgets/app_progress_lndicator.dart';
import 'package:anbackup/widgets/hero_title.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';
import 'package:path_provider/path_provider.dart';

class StartBackup extends StatefulWidget {
  const StartBackup({
    Key? key,
    required this.device,
    required this.packages,
  }) : super(key: key);
  final Device device;
  final Map<String, BackupPackage> packages;

  @override
  State<StartBackup> createState() => _StartBackupState();
}

class _StartBackupState extends State<StartBackup> {
  late String deviceName = "${widget.device.brand} ${widget.device.marketName}";
  late int num = widget.packages.length;
  bool isDone = false;
  bool isData = false;
  late Backup backup;
  int numIndex = 0;
  String cuurentPackage = "";
  bool _skipData = false;

  @override
  void initState() {
    _startBackup();
    super.initState();
  }

  @override
  void dispose() {
    debugPrint("dispose");
    backup.dispose();
    super.dispose();
  }

  _startBackup() async {
    final savePath = await getApplicationDocumentsDirectory();
    backup = Backup(
      device: widget.device,
      savePath: "${savePath.path}/AnBackup",
    );

    for (var package in widget.packages.entries) {
      numIndex++;
      cuurentPackage = package.key;
      try {
        if (package.value.apk) {
          isData = false;
          _update();
          await backup.backupApk(package.key);
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
                  title: Text("切换 root 失败,将不会备份应用数据,请关闭 Magisk Hide 后重试; $e"),
                  severity: InfoBarSeverity.error,
                );
              });
            }
            _skipData = true;
          }
          await backup.backupData(package.key);
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    backup.generateConfig();

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
            isDone ? "备份 $deviceName 完成" : "正在备份 $deviceName 的数据",
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
