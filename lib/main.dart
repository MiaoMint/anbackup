import 'package:anbackup/pages/home_page.dart';
import 'package:anbackup/utils/package_info.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  await PackageInfoUtil.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 500),
    minimumSize: Size(800, 500),
    center: true,
    skipTaskbar: false,
    title: "AnBackup",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      navigatorKey: rootNavigatorKey,
      title: 'AnBackup',
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        visualDensity: VisualDensity.standard,
        fontFamily: "Microsoft Yahei",
      ),
      theme: FluentThemeData(
        visualDensity: VisualDensity.standard,
        fontFamily: "Microsoft Yahei",
      ),
      home: const HomePage(),
    );
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();
