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
  Widget build(BuildContext context) => CupertinoApp(
        theme: Consts.theme,
        home: ListenableView(manager.all,
            builder: (all) => all.isNotEmpty ? AlbumViewer(all) : loadingView),
      );

  Widget get loadingView => const Center(
        child: CupertinoActivityIndicator(),
      );
}
