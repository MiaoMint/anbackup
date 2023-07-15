import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    Key? key,
    required this.package,
    this.isData = false,
    this.size = 128,
  }) : super(key: key);
  final bool isData;
  final String package;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: package,
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Image.network(
              "https://icon.0n0.dev/$package",
              width: size,
              height: size,
              fit: BoxFit.contain,
            ),
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            Positioned.fill(
              child: Center(
                  child: Icon(
                isData ? material.Icons.data_usage : material.Icons.android,
                size: size / 3,
              )),
            ),
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  width: size / 2,
                  height: size / 2,
                  child: const ProgressRing(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
