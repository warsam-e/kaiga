import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:kaiga/main.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

export 'nav.dart';
export 'footer.dart';
export 'filter.dart';

class AssetViewer extends StatefulWidget {
  final ValueNotifier<KaigaAsset?> asset;
  const AssetViewer(this.asset, {super.key});

  @override
  AssetViewerState createState() => AssetViewerState();
}

class AssetViewerState extends State<AssetViewer> {
  ValueNotifier<KaigaAsset?> get asset => widget.asset;

  File? file;

  VideoPlayerController? controller;

  final volumeController = VolumeController();

  @override
  void initState() {
    super.initState();
    asset.addListener(init);
    init();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  reset() {
    file = null;
    controller?.dispose();
    controller = null;
  }

  init() async {
    reset();
    if (asset.value == null) return;
    if (!asset.value!.isVideo) return;
    asset.value!.file.addListener(initFile);
    initFile();
  }

  initFile() {
    final item = asset.value!.file.value;
    if (item == null) return;
    setState(() {
      file = item.file;
    });
    initVideo(asset.value!);
  }

  initVideo(KaigaAsset asset) async {
    final file = asset.file.value;
    if (file == null) return;
    controller = VideoPlayerController.file(file.file);
    controller!.setLooping(true);
    await controller!.initialize();
    setState(() {});
    volumeController.setVolume(0.2, showSystemUI: false);
    await controller!.play();
  }

  @override
  Widget build(BuildContext context) => ListenableView(
        asset,
        builder: (a) => a != null
            ? a.isImage
                ? imageView(a)
                : a.isVideo
                    ? videoView
                    : loadingView
            : loadingView,
      );

  Widget get loadingView => const Center(
        child: CupertinoActivityIndicator(),
      );

  Widget imageView(KaigaAsset asset) => Center(
        child: AssetEntityImage(
          asset.entity,
        ),
      );

  Widget get videoView =>
      controller != null ? VideoPlayer(controller!) : loadingView;
}
