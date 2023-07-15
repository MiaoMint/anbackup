import 'dart:convert';
import 'dart:io';

import 'package:anbackup/model/backup_config.dart';
import 'package:anbackup/pages/backup_restore/start_restore.dart';
import 'package:anbackup/utils/router.dart';
import 'package:anbackup/widgets/apk_select.dart';
import 'package:anbackup/widgets/hero_header.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';
import 'package:path_provider/path_provider.dart';

class BackupSelect extends StatefulWidget {
  const BackupSelect({
    Key? key,
    required this.device,
  }) : super(key: key);
  final Device device;

  @override
  State<BackupSelect> createState() => _BackupSelectState();
}

class _BackupSelectState extends State<BackupSelect> {
  //  key 备份路径 value 为备份配置
  final Map<String, BackupConfig> _backupMap = {};

  @override
  void initState() {
    _getBackupList();
    super.initState();
  }

  _getBackupList() async {
    final path = await getApplicationDocumentsDirectory();
    final dir = Directory("${path.path}/AnBackup");
    _backupMap.clear();
    if (!dir.existsSync()) {
      return;
    }
    for (var file in dir.listSync()) {
      if (file is! Directory) {
        continue;
      }
      final backupConfigFile = File("${file.path}/config.json");
      if (!backupConfigFile.existsSync()) {
        continue;
      }
      try {
        final backupConfig = BackupConfig.fromJson(
          jsonDecode(backupConfigFile.readAsStringSync()),
        );
        _backupMap[file.path] = backupConfig;
      } catch (e) {
        debugPrint(e.toString());
        continue;
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: HeroHeader(
              "选择需要恢复的备份",
              trailing: Row(
                children: [
                  IconButton(
                    icon: const Icon(FluentIcons.refresh),
                    onPressed: () {
                      _getBackupList();
                    },
                  )
                ],
              ),
            ),
          ),
          if (_backupMap.isEmpty)
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "（＞人＜；）",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("没有找到备份文件"),
                ],
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  for (var backup in _backupMap.entries)
                    ListTile(
                      title: Text(
                        "${backup.value.device.brand} ${backup.value.device.marketName}",
                      ),
                      subtitle: Text(
                        "${backup.value.time.toString()} 应用数量：${backup.value.package.length}",
                      ),
                      onPressed: () {
                        RouterUtil.push(ApkSelect(
                          title: "选择需要恢复的应用",
                          device: widget.device,
                          buildPackages: () async {
                            return backup.value.package.values.toList();
                          },
                          onNextStep: (packages) {
                            packages.updateAll((key, value) {
                              value.apks = backup.value.package[key]!.apks;
                              return value;
                            });

                            RouterUtil.push(StartRestore(
                              device: widget.device,
                              backupConfig: backup.value..package = packages,
                              basePath: backup.key,
                            ));
                          },
                        ));
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
