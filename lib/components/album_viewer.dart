import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:kaiga/main.dart';

class AlbumViewer extends StatefulWidget {
  final List<KaigaAsset> all;
  const AlbumViewer(this.all, {super.key});

  @override
  AlbumViewerState createState() => AlbumViewerState();
}

class AlbumViewerState extends State<AlbumViewer> {
  List<KaigaAsset> get all => widget.all;

  final manager = KaigaManager();

  final currentAsset = ValueNotifier<KaigaAsset?>(null);

  final showingControls = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    manager.currentAssetId.addListener(update);
    update();
  }

  @override
  void dispose() {
    manager.currentAssetId.removeListener(update);
    super.dispose();
  }

  update() {
    setCurrentAsset(null);
    final id = manager.currentAssetId.value;
    if (id != null) setCurrentAsset(manager.getAsset(id));
  }

  void setCurrentAsset(KaigaAsset? asset) => currentAsset.value = asset;

  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get bottom => viewPadding.bottom;

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
