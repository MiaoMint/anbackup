import 'dart:async';

import 'package:anbackup/widgets/grid_device_tile.dart';
import 'package:anbackup/widgets/tips_card.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_adb/flutter_adb.dart';

class DeviceSelect extends StatefulWidget {
  const DeviceSelect({
    Key? key,
    required this.onSelected,
  }) : super(key: key);

  final void Function(Device device) onSelected;

  @override
  State<DeviceSelect> createState() => _DeviceSelectState();
}

class _DeviceSelectState extends State<DeviceSelect>
    with WidgetsBindingObserver {
  final List<Device> _devices = [];
  Timer? _timer;

  @override
  void initState() {
    refreshDevice();
    super.initState();
  }

  refreshDevice() async {
    _timer?.cancel();
    final devices_ = await FlutterAdb.devices();
    if (!mounted) {
      return;
    }
    debugPrint("refreshDevice");
    setState(() {
      _devices.clear();
      _devices.addAll(devices_);
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      refreshDevice();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_devices.isEmpty)
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: ProgressRing(),
                ),
                SizedBox(height: 16),
                Center(
                  child: Text("如果一直没有找到设备，请检查设备是否连接并且已经开启 USB 调试模式。"),
                ),
              ],
            ),
          )
        else
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const TipsCard(
                  child: Text("请先选择设备再继续"),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: ((context, constraints) {
                    return GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: constraints.maxWidth ~/ 230,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _devices
                          .map(
                            (e) => Hero(
                              tag: e.serialNumber,
                              child: GridDeviceTile(
                                version: e.version,
                                codeName: e.codeName,
                                model: e.model,
                                brand: e.brand,
                                marketName: e.marketName,
                                serialNumber: e.serialNumber,
                                onPressed: () {
                                  widget.onSelected(e);
                                },
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }),
                )
              ],
            ),
          )
      ],
    );
  }
}
