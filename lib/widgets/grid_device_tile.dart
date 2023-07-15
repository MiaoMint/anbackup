import 'package:anbackup/api/gsmarena.dart';
import 'package:fluent_ui/fluent_ui.dart';

class GridDeviceTile extends StatefulWidget {
  const GridDeviceTile({
    Key? key,
    required this.version,
    required this.codeName,
    required this.model,
    required this.brand,
    required this.serialNumber,
    required this.marketName,
    this.onPressed,
  }) : super(key: key);
  final String version;
  final String brand;
  final String marketName;
  final String model;
  final String codeName;
  final String serialNumber;
  final Function()? onPressed;

  @override
  State<GridDeviceTile> createState() => _GridDeviceTileState();
}

class _GridDeviceTileState extends State<GridDeviceTile> {
  String? _image;

  @override
  void initState() {
    _getImage();
    super.initState();
  }

  _getImage() async {
    final url = await GSMArena.getImage(widget.brand, widget.marketName);
    if (mounted) {
      setState(() {
        _image = url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Button(
        onPressed: widget.onPressed ?? () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Image.network(
                _image!,
                fit: BoxFit.cover,
                height: 100,
              )
            else
              const SizedBox(
                height: 100,
                child: Center(
                  child: Icon(
                    FluentIcons.cell_phone,
                    size: 50,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              "${widget.brand} ${widget.marketName}",
            ),
            Text("Android ${widget.version}"),
            Text(
              widget.codeName,
            ),
            Text(
              widget.serialNumber,
            ),
          ],
        ),
      ),
    );
  }
}
