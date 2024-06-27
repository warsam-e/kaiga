import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:kaiga/main.dart';
import 'package:kaiga/manager/mod.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

export 'nav.dart';
export 'footer.dart';
export 'filter.dart';

class AssetViewer extends StatefulWidget {
  final KaigaAsset asset;
  const AssetViewer(this.asset, {super.key});

  @override
  AssetViewerState createState() => AssetViewerState();
}

class AssetViewerState extends State<AssetViewer> {
  KaigaAsset get asset => widget.asset;

  File? file;

  VideoPlayerController? controller;

  final volumeController = VolumeController();

  @override
  void initState() {
    super.initState();
    if (asset.isVideo) init();
  }

  @override
  void dispose() {
    reset();
    super.dispose();
  }

  reset() {
    asset.assetFile.file.removeListener(initFile);
    file = null;
    controller?.dispose();
    controller = null;
  }

  init() async {
    reset();
    asset.assetFile.file.addListener(initFile);
    initFile();
  }

  initFile() {
    final item = asset.assetFile.file.value;
    if (item == null) return;
    setState(() {
      file = item;
    });
    initVideo(asset);
  }

  initVideo(KaigaAsset asset) async {
    final file = asset.assetFile.file.value;
    if (file == null) return;
    controller = VideoPlayerController.file(file);
    controller!.setLooping(true);
    await controller!.initialize();
    setState(() {});
    final volume = await volumeController.getVolume();
    if (volume > 0.2) volumeController.setVolume(0.2, showSystemUI: false);
    await controller!.play();
  }

  @override
  Widget build(BuildContext context) => asset.isImage
      ? imageView(asset)
      : asset.isVideo
          ? videoView
          : loadingView;

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
