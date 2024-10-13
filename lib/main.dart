import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:kaiga/main.dart';

export 'utils/consts.dart';
export 'components/mod.dart';
export 'manager/mod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initApp().then((_) => runApp(const App()));
}

Future initApp() async {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: SystemUiOverlay.values);
}

/// The main Kaiga app widget.
/// This view isn't tampered with directly, but is the root of the Kaiga app.
/// Since Kaiga is a photo and video viewer, it doesn't necessarily need tabs
/// or much navigation.
/// It's a simple app that displays media files from the device.
class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  final manager = KaigaManager();

  @override
  void initState() {
    super.initState();
    manager.init();
  }

  @override
  Widget build(BuildContext context) => const CupertinoApp(
        theme: Consts.theme,
        home: AlbumViewer(),
      );
}
