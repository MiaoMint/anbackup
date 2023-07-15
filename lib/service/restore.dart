import 'dart:io';

import 'package:anbackup/model/backup_config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';

class Restore {
  final Device device;
  final String basePath;
  bool _isDisposed = false;

  Restore({
    required this.device,
    required this.basePath,
  });

  restoreApk(BackupPackage backupPackage) async {
    if (_isDisposed) {
      throw "disposed";
    }
    final path = "$basePath/${backupPackage.package}";
    final dir = Directory(path);
    if (!dir.existsSync()) {
      throw "file not exists";
    }
    await device.installSplitApk(
      backupPackage.apks!.map((e) => "$path/$e").toList(),
    );
  }

  restoreData(String package) async {
    if (_isDisposed) {
      throw "disposed";
    }
    final path = "$basePath/$package/data";
    final dir = Directory(path);
    if (!dir.existsSync()) {
      throw "file not exists";
    }
    // 获取应用权限组
    final premStr = await device.runCommand([
      '''bash -c 'cd /data/data/ && ls -l | grep "$package"' ''',
    ]);
    debugPrint(premStr);

    // 正则获取
    final premGroup = RegExp(r"u\d+_a\d+").firstMatch(premStr);
    if (premGroup == null) {
      throw "prem not found";
    }

    // 先 push 到设备 /sdcard/anbackup 目录下
    final toPath = "/sdcard/anbackup/$package/";
    // for (var file in dir.listSync(recursive: true)) {
    //   if (_isDisposed) {
    //     return;
    //   }
    //   await _pushFile(path, toPath, file);
    // }

    debugPrint(await device.pushFile(
      "$path/.",
      toPath,
    ));

    // 再从 /sdcard/anbackup 目录下拷贝到 /data/data 目录下
    debugPrint(await device.runCommand([
      "bash -c 'cp -r $toPath. /data/data/$package/.'",
    ]));

    // 删除 /sdcard/anbackup 目录下的文件
    debugPrint(await device.runCommand([
      "bash -c 'rm -rf $toPath'",
    ]));

    debugPrint(
        "bash -c 'chown -R ${premGroup.group(0)!}:${premGroup.group(0)!} /data/data/$package/.'");
    // // 修复权限
    debugPrint(await device.runCommand([
      "bash -c 'chown -R ${premGroup.group(0)!}:${premGroup.group(0)!} /data/data/$package/.'",
    ]));
  }

  // _pushFile(String path, String packagePath, FileSystemEntity file) async {
  //   if (_isDisposed) {
  //     return;
  //   }
  //   if (file is File) {
  //     final fileName = file.path.replaceAll(path, "").replaceAll("\\", "/");
  //     await device.pushFile(file.path, "$packagePath$fileName");
  //     debugPrint("push $packagePath$fileName");
  //   }

  //   if (file is Directory) {
  //     for (var f in file.listSync()) {
  //       _pushFile(path, packagePath, f);
  //     }
  //   }
  // }

  dispose() {
    _isDisposed = true;
  }
}
