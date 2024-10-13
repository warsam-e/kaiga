import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kaiga/main.dart';

/// The AlbumViewer class is a Flutter widget that displays an album in the Kaiga app.
///
/// This handles the display of the albums, the navigation and footer controls.
class AlbumViewer extends StatefulWidget {
  const AlbumViewer({super.key});

  @override
  AlbumViewerState createState() => AlbumViewerState();
}

class AlbumViewerState extends State<AlbumViewer> {
  final manager = KaigaManager();

  final showingControls = ValueNotifier(true);

  final currentAssetId = ValueNotifier<String?>(null);
  final currentAsset = ValueNotifier<KaigaAsset?>(null);

  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get bottom => viewPadding.bottom;

  @override
  void initState() {
    super.initState();
    manager.list.addListener(init);
    init();
  }

  @override
  void dispose() {
    manager.list.removeListener(init);
    super.dispose();
  }

  init() async {
    currentAsset.value = null;
    if (manager.list.value.isEmpty) return;

    final item = await manager.list.value.first.init();
    currentAsset.value = item;
  }

  toggleShowingControls() {
    showingControls.value = !showingControls.value;
    if (!showingControls.value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
  }

  imageClickHandler(Widget child) =>
      GestureDetector(onTap: toggleShowingControls, child: child);

  showingControlsView(Widget child) => ListenableView(
        showingControls,
        builder: (value) => AnimatedOpacity(
          opacity: value ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          imageClickHandler(AssetViewer(currentAsset)),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: showingControlsView(AssetViewerNav(currentAsset))),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: showingControlsView(AssetViewerFooter(currentAsset)))
        ],
      );
}
