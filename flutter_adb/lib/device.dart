import 'dart:async';

import 'package:flutter_adb/flutter_adb.dart';

class Device {
  final String name;
  final String version;
  final String brand;
  final String marketName;
  final String model;
  final String codeName;
  final String serialNumber;
  final Map<String, String> properties;

  Device({
    required this.name,
    required this.version,
    required this.brand,
    required this.marketName,
    required this.model,
    required this.codeName,
    required this.serialNumber,
    required this.properties,
  });

  static fromJson(Map<String, dynamic> json) {
    return Device(
      name: json["name"],
      version: json["version"],
      brand: json["brand"],
      marketName: json["marketName"],
      model: json["model"],
      codeName: json["codeName"],
      serialNumber: json["serialNumber"],
      properties: {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "version": version,
      "brand": brand,
      "marketName": marketName,
      "model": model,
      "codeName": codeName,
      "serialNumber": serialNumber,
    };
  }

  Future<String> runCommand(List<String> arguments) async {
    final process = await FlutterAdb.execute([
      "-s",
      serialNumber,
      "shell",
      ...arguments,
    ]);
    return process.stdout.toString();
  }

  /// Pushes a file to the device.
  Future<String> pushFile(String filename, String toPath) async {
    final process = await FlutterAdb.execute([
      "-s",
      serialNumber,
      "push",
      filename,
      toPath,
    ]);
    final output = process.stdout.toString();
    if (output.contains("error")) {
      throw output;
    }
    return filename;

    // 不知道为啥 adb 突然没进度了调试不了就暂时弃用
    // final streamController = StreamController<String>();
    // streamController.stream.listen((event) {
    //   print(event);
    // });

    // print("push $filename to $toPath on $serialNumber ");

    // final process = await FlutterAdb.start([
    //   "-s",
    //   serialNumber,
    //   "push",
    //   filename,
    //   toPath,
    // ]);

    // process.stderr.transform(utf8.decoder).listen((event) {
    //   streamController.add(event);
    // });

    // Stream<List<int>> stdoutStream = process.stdout;
    // stdoutStream
    //     .transform(utf8.decoder)
    //     .transform(const LineSplitter())
    //     .listen((String data) {
    //   streamController.add(data);
    // });
  }

  /// Pulls a file from the device.
  Future<String> pullFile(String filename, String toPath) async {
    final process = await FlutterAdb.execute([
      "-s",
      serialNumber,
      "pull",
      filename,
      toPath,
    ]);
    final output = process.stdout.toString();
    if (output.contains("error")) {
      throw output;
    }
    return filename;
  }

  /// Deletes a file from the device.
  Future<String> deleteFile(String filename) async {
    final process = await FlutterAdb.execute([
      "-s",
      serialNumber,
      "shell",
      "rm",
      filename,
    ]);
    final output = process.stdout.toString();
    if (output.contains("error")) {
      throw output;
    }
    return filename;
  }

  Future<void> root() async {
    final process = await FlutterAdb.execute([
      "-s",
      serialNumber,
      "root",
    ]);
    var output = process.stdout.toString();
    if (output.contains("cannot") || output.contains("setting")) {
      throw output;
    }
  }

  // Install apk
  Future<String> installApk(String filename) async {
    final process = await FlutterAdb.execute([
      "-s",
      serialNumber,
      "install",
      "-r",
      filename,
    ]);
    final output = process.stdout.toString();
    if (output.contains("error")) {
      throw output;
    }
    return filename;
  }

  // Install split apk
  Future<void> installSplitApk(List<String> apks) async {
    final process = await FlutterAdb.execute([
      "-s",
      serialNumber,
      "install-multiple",
      ...apks,
    ]);
    final output = process.stdout.toString();
    if (output.contains("error")) {
      throw output;
    }
  }

  /// Returns a list of installed packages.
  Future<List<String>> listPackages({bool is3 = true}) async {
    final process = await FlutterAdb.execute(
      ["-s", serialNumber, "shell", "pm", "list", "packages", if (is3) "-3"],
    );
    final output = process.stdout.toString();
    return output.split("\n").map((e) {
      return e.split(":").last.trim();
    }).toList();
  }

  /// Returns a screenshot of the device.
  Future<String> screenshot(String filename) async {
    const tempPath = "/data/local/tmp/flutterAdb_temp.png";

    await FlutterAdb.execute([
      "-s",
      serialNumber,
      "shell",
      "screencap",
      tempPath,
    ]);

    await pullFile(tempPath, filename);
    await deleteFile(tempPath);
    return filename;
  }

  Future<void> shutdown() async {
    final process = await FlutterAdb.execute([
      "-s",
      serialNumber,
      "shutdown",
    ]);
    final output = process.stdout.toString();
    if (output.isEmpty) {
      return;
    }
    throw output;
  }
}
