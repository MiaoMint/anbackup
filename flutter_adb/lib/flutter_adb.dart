library flutter_adb;

import 'dart:io';

import 'package:flutter_adb/device.dart';

export 'package:flutter_adb/device.dart';

mixin FlutterAdb {
  static String? adbPath;
  static Future<String?> get version => _getVersion();

  /// Returns the path to the ADB executable.
  static Future<ProcessResult> execute(List<String> arguments) {
    return Process.run(adbPath ?? "adb", arguments);
  }

  static Future<Process> start(
    List<String> arguments,
  ) {
    return Process.start(
      adbPath ?? "adb",
      arguments,
      runInShell: true,
    );
  }

  ///  Returns the version of the ADB executable.
  static Future<String?> _getVersion() async {
    try {
      final result = await execute(["version"]);
      final version = RegExp(r"version (\d+\.\d+\.\d+)")
          .firstMatch(result.stdout.toString())
          ?.group(1);
      return version;
    } catch (e) {
      throw "ADB not found. Please install it from https://developer.android.com/studio/releases/platform-tools";
    }
  }

  /// Connects to the device with the given IP address.
  /// Throws an error if the connection fails.
  static connect(String ip) async {
    final result = await execute(["connect", ip]);
    final output = result.stdout.toString();
    if (output.contains("already connected") ||
        output.contains("connected to")) {
      return;
    }
    throw "Failed to connect to $ip";
  }

  // Disconnects from the device with the given IP address.
  static Future<List<Device>> devices() async {
    final result = await execute(["devices"]);
    final output = result.stdout.toString();
    final devices = <Device>[];
    for (final line in output.split("\n")) {
      if (line.contains("List of devices attached")) {
        continue;
      }
      if (line.isEmpty) {
        continue;
      }
      final match = RegExp(r"(.*)\tdevice").firstMatch(line);
      if (match == null) {
        continue;
      }
      final serialNumber = match.group(1);
      if (serialNumber == null) {
        continue;
      }
      final device = await getDevice(serialNumber);
      devices.add(device);
    }
    return devices;
  }

  /// Returns a list of all connected devices.
  static Future<Device> getDevice(String serialNumber) async {
    final result = await execute([
      "-s",
      serialNumber,
      "shell",
      "getprop",
    ]);
    final output = result.stdout.toString();
    final properties = <String, String>{};
    for (final line in output.split("\n")) {
      final match = RegExp(r"\[(.*)\]: \[(.*)\]").firstMatch(line);
      if (match == null) {
        continue;
      }
      final key = match.group(1);
      final value = match.group(2);
      if (key == null || value == null) {
        continue;
      }
      properties[key] = value;
    }
    return Device(
      name: properties["ro.product.name"] ?? "",
      version: properties["ro.build.version.release"] ?? "",
      brand: properties["ro.product.brand"] ?? "",
      marketName: properties["ro.product.marketname"] ?? "",
      model: properties["ro.product.model"] ?? "",
      codeName: properties["ro.product.device"] ?? "",
      serialNumber: serialNumber,
      properties: properties,
    );
  }
}
