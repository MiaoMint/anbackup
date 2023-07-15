import 'dart:convert';
import 'dart:io';

import 'package:anbackup/model/backup_config.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';

class Backup {
  final Device device;
  String savePath;
  bool _isDisposed = false;
  // 记录已经备份的应用
  final Map<String, BackupPackage> _backedPackages = {};

  Backup({
    required this.device,
    required this.savePath,
  }) {
    // 获取时间
    final now = DateTime.now();
    final time =
        "${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}-${now.second}";
    Directory(
      "$savePath/${device.brand}-${device.marketName}-$time",
    ).createSync(recursive: true);
    savePath = "$savePath/${device.brand}-${device.marketName}-$time";
  }

  backupApk(String package) async {
    if (_isDisposed) {
      throw "disposed";
    }
    // 先获取应用的apk路径
    final paths = await device.runCommand([
      "pm path",
      package,
    ]);

    final fileNames = <String>[];

    for (var path in paths.replaceAll("package:", "").split("\n")) {
      if (_isDisposed) {
        return;
      }
      if (path.isEmpty) {
        continue;
      }
      path = path.trim();
      // 获取文件名
      final fileName = path.split("/").last;

      Directory("$savePath\\$package\\").createSync(recursive: true);

      // 拷贝文件
      await device.pullFile(path, "$savePath\\$package\\$fileName");

      fileNames.add(fileName);
    }

    _backedPackages[package] = BackupPackage(
      package: package,
      apks: fileNames,
      apk: true,
    );
  }

  backupData(String package) async {
    if (_isDisposed) {
      throw "disposed";
    }
    Directory("$savePath\\$package\\data").createSync(recursive: true);
    final packagePath = "/data/data/$package/.";
    // 获取所有文件
    final files = await device.runCommand([
      "find $packagePath -type f  -not -empty",
    ]);
    for (var file in files.split("\n")) {
      if (_isDisposed) {
        return;
      }
      if (file.isEmpty) {
        continue;
      }
      file = file.trim();
      // 获取文件名
      final fileName = file.split("/").last;

      try {
        // 创建文件夹
        final dir = file.replaceAll(fileName, "").replaceAll(packagePath, "");
        Directory("$savePath\\$package\\data\\$dir")
            .createSync(recursive: true);

        // 拷贝文件
        await device.pullFile(
          file,
          "$savePath\\$package\\data\\$dir\\$fileName",
        );
      } catch (e) {
        debugPrint(e.toString());
        continue;
      }
    }
    _backedPackages[package] = BackupPackage(
      package: package,
      apks: _backedPackages[package]?.apks,
      apk: _backedPackages[package]?.apk ?? false,
      data: true,
    );
  }

  // 生成 config.json
  generateConfig() {
    final config = BackupConfig(
      device: device,
      package: _backedPackages,
      time: DateTime.now(),
      directory: null,
    );
    File("$savePath\\config.json").writeAsStringSync(
      jsonEncode(config.toJson()),
    );
  }

  // 销毁对象
  dispose() {
    _isDisposed = true;
  }
}
