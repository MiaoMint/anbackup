import 'package:flutter_adb/flutter_adb.dart';

class BackupConfig {
  late Device device;
  late Map<String, BackupPackage> package;
  Map<String, String>? directory;
  late DateTime time;
  BackupConfig({
    required this.device,
    required this.package,
    required this.time,
    this.directory,
  });

  static fromJson(Map<String, dynamic> json) {
    return BackupConfig(
      device: Device.fromJson(json["device"]),
      package: (json["package"] as Map).map(
        (key, value) {
          return MapEntry(key, BackupPackage.fromJson(value));
        },
      ),
      directory: json["directory"],
      time: DateTime.parse(json["time"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "device": device.toJson(),
      "package": package.map((key, value) => MapEntry(key, value.toJson())),
      "time": time.toIso8601String(),
      "directory": directory,
    };
  }
}

class BackupPackage {
  late String package;
  late List<String>? apks;
  late bool data;
  late bool apk;

  BackupPackage({
    required this.package,
    this.apks,
    this.apk = false,
    this.data = false,
  });

  static fromJson(Map<String, dynamic> json) {
    return BackupPackage(
      package: json["package"],
      apks: List<String>.from(json["apks"]),
      data: json["data"],
      apk: json["apk"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "package": package,
      "apks": apks,
      "apk": apk,
      "data": data,
    };
  }
}
