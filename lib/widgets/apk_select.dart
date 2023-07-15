import 'package:anbackup/model/backup_config.dart';
import 'package:anbackup/widgets/hero_header.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';
import 'package:flutter/material.dart' as material;

class ApkSelect extends StatefulWidget {
  const ApkSelect({
    Key? key,
    required this.title,
    required this.device,
    required this.buildPackages,
    required this.onNextStep,
  }) : super(key: key);
  final String title;
  final Device device;
  final Future<List<BackupPackage>> Function() buildPackages;
  final Function(Map<String, BackupPackage> packages) onNextStep;

  @override
  State<ApkSelect> createState() => _ApkSelectState();
}

class _ApkSelectState extends State<ApkSelect> {
  // 显示的应用列表
  final List<BackupPackage> _packages = [];
  // 所有应用列表
  final List<BackupPackage> _allPackages = [];
  // 选择的应用列表
  final List<String> _selectedApkPackages = [];
  // 选择的数据列表
  final List<String> _selectedDataPackages = [];

  @override
  void initState() {
    getPackages();
    super.initState();
  }

  getPackages() async {
    final packages = await widget.buildPackages();
    _allPackages.addAll(packages);
    _packages.addAll(packages);
    setState(() {});
  }

  searchPackage(String searchText) async {
    _packages.clear();
    for (var package in _allPackages) {
      if (package.package.toLowerCase().contains(searchText.toLowerCase())) {
        _packages.add(package);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FluentTheme.of(context).micaBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: HeroHeader(
              widget.title,
              trailing: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: TextBox(
                      placeholder: "搜索包名",
                      onChanged: (value) {
                        if (value.isEmpty) {
                          _packages.clear();
                          _packages.addAll(_allPackages);
                          setState(() {});
                        }
                      },
                      onSubmitted: (value) {
                        searchPackage(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Checkbox(
                    checked:
                        _selectedApkPackages.length == _allPackages.length &&
                            _selectedDataPackages.length == _allPackages.length,
                    onChanged: (value) {
                      _selectedApkPackages.clear();
                      _selectedDataPackages.clear();
                      if (value!) {
                        for (var package in _allPackages) {
                          _selectedApkPackages.add(package.package);
                          _selectedDataPackages.add(package.package);
                        }
                      }
                      setState(() {});
                    },
                    content: const Text("全选"),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    child: (const Text("下一步")),
                    onPressed: () {
                      final packages = <String, BackupPackage>{};
                      for (var package in _allPackages) {
                        final packageName = package.package;
                        final apk = _selectedApkPackages.contains(
                          packageName,
                        );
                        final data = _selectedDataPackages.contains(
                          packageName,
                        );
                        if (apk || data) {
                          packages[packageName] = BackupPackage(
                            package: packageName,
                            apk: apk,
                            data: data,
                          );
                        }
                      }
                      widget.onNextStep(packages);
                    },
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(builder: ((context, constraints) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: constraints.maxWidth ~/ 190,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _packages.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (constext, index) {
                  final package = _packages[index];
                  final packageName = package.package;
                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.network(
                            "https://icon.0n0.dev/$packageName",
                          ),
                        ),
                        const SizedBox(height: 16),
                        Tooltip(
                          message: package.package,
                          child: Text(
                            package.package,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (package.apk)
                              Expanded(
                                  child: Tooltip(
                                message: "安装包",
                                child: ToggleButton(
                                  checked: _selectedApkPackages.contains(
                                    package.package,
                                  ),
                                  onChanged: (value) {
                                    if (value) {
                                      _selectedApkPackages.add(packageName);
                                    } else {
                                      _selectedApkPackages.remove(packageName);
                                    }
                                    setState(() {});
                                  },
                                  child: const Icon(material.Icons.android),
                                ),
                              )),
                            const SizedBox(width: 8),
                            if (package.data)
                              Expanded(
                                  child: Tooltip(
                                message: "数据文件",
                                child: ToggleButton(
                                  checked: _selectedDataPackages.contains(
                                    packageName,
                                  ),
                                  onChanged: (value) {
                                    if (value) {
                                      _selectedDataPackages.add(packageName);
                                    } else {
                                      _selectedDataPackages.remove(packageName);
                                    }
                                    setState(() {});
                                  },
                                  child: const Icon(material.Icons.data_usage),
                                ),
                              )),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            })),
          ),
        ],
      ),
    );
  }
}
