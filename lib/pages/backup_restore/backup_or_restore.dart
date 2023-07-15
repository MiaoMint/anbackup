import 'dart:io';

import 'package:anbackup/model/backup_config.dart';
import 'package:anbackup/pages/backup_restore/backup_select.dart';
import 'package:anbackup/pages/backup_restore/start_backup.dart';
import 'package:anbackup/utils/router.dart';
import 'package:anbackup/widgets/apk_select.dart';
import 'package:anbackup/widgets/big_button.dart';
import 'package:anbackup/widgets/hero_header.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_adb/flutter_adb.dart';
import 'package:path_provider/path_provider.dart';

class BackupOrRestorePage extends StatefulWidget {
  const BackupOrRestorePage({
    Key? key,
    required this.device,
  }) : super(key: key);
  final Device device;

  @override
  State<BackupOrRestorePage> createState() => _BackupOrRestorePageState();
}

class _BackupOrRestorePageState extends State<BackupOrRestorePage> {
  String _screenShotPath = "";

  @override
  void initState() {
    screenshot();
    super.initState();
  }

  // 截图
  screenshot() async {
    final tempDir = await getTemporaryDirectory();
    final path = await widget.device.screenshot(
        "${tempDir.path}/${widget.device.serialNumber}_anbackup_screenshot.png");
    // print(path);
    setState(() {
      _screenShotPath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: HeroHeader(
              "选择操作",
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Hero(
                    tag: widget.device.serialNumber,
                    child: SizedBox(
                      width: 200,
                      child: _screenShotPath.isEmpty
                          ? const SizedBox()
                          : Image.file(
                              File(_screenShotPath),
                              key: ValueKey(_screenShotPath),
                            ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 80,
                  color: FluentTheme.of(context).inactiveColor.withOpacity(0.2),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.device.brand} ${widget.device.marketName}',
                      style: FluentTheme.of(context).typography.title,
                    ),
                    Text('Android ${widget.device.version}'),
                    Text("型号: ${widget.device.model}"),
                    Text("代号: ${widget.device.codeName}"),
                    Text(widget.device.serialNumber),
                    const SizedBox(height: 8),
                    BigButton(
                      icon: material.Icons.backup_outlined,
                      text: "备份数据",
                      onPressed: () {
                        RouterUtil.push(
                          ApkSelect(
                            title: "选择要备份的应用",
                            device: widget.device,
                            buildPackages: () async {
                              final packages =
                                  await widget.device.listPackages();
                              return packages
                                  .map((e) => BackupPackage(
                                        package: e,
                                        apk: true,
                                        data: true,
                                      ))
                                  .toList();
                            },
                            onNextStep: (packages) {
                              RouterUtil.push(StartBackup(
                                device: widget.device,
                                packages: packages,
                              ));
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    BigButton(
                      icon: material.Icons.restore,
                      text: "还原数据",
                      onPressed: () {
                        RouterUtil.push(
                          BackupSelect(device: widget.device),
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
