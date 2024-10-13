import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:kaiga/main.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

export 'nav.dart';
export 'footer.dart';

/// The AssetViewer widget in the Kaiga app.
///
/// This widget displays an asset in the Kaiga app.
///
/// It handles the display of the asset, the image and video views.
class AssetViewer extends StatefulWidget {
  final ValueNotifier<KaigaAsset?> asset;
  const AssetViewer(this.asset, {super.key});

  @override
  AssetViewerState createState() => AssetViewerState();
}

class AssetViewerState extends State<AssetViewer> {
  ValueNotifier<KaigaAsset?> get currentAsset => widget.asset;

  KaigaAsset? asset;
  File? file;

  Timer? playTimer;

  VideoPlayerController? controller;

  final volumeController = VolumeController();

  @override
  void initState() {
    super.initState();
    currentAsset.addListener(init);
    init();
  }

  @override
  void dispose() {
    currentAsset.removeListener(init);
    reset();
    super.dispose();
  }

  reset() {
    playTimer?.cancel();
    controller?.dispose();
    controller = null;
    setAsset(null);
    setFile(null);
    currentAsset.value?.assetFile.file.removeListener(initFile);
  }

  init() async {
    reset();
    if (currentAsset.value == null) return;
    setAsset(currentAsset.value!);
    if (!asset!.isVideo) return;
    currentAsset.value?.assetFile.file.addListener(initFile);
    initFile();
  }

  initFile() {
    final item = asset!.assetFile.file.value;
    if (item == null) return;
    setFile(item);
    initVideo(asset!);
  }

  initVideo(KaigaAsset asset) async {
    final file = asset.assetFile.file.value;
    if (file == null) return;
    controller = VideoPlayerController.file(file);
    controller!.setLooping(true);
    await controller!.initialize();
    setState(() {});

    playTimer = Timer.periodic(const Duration(seconds: 1), alwaysPlay);

    alwaysPlay(null);
  }

  alwaysPlay(Timer? _) async {
    if (controller == null) return;
    if (controller!.value.isPlaying) return;
    await controller!.play();
  }

  void setAsset(KaigaAsset? asset) => setState(() => this.asset = asset);
  void setFile(File? file) => setState(() => this.file = file);

  @override
  Widget build(BuildContext context) => asset != null
      ? asset!.isImage
          ? imageView(asset!)
          : asset!.isVideo
              ? videoView
              : loadingView
      : loadingView;

  Widget get loadingView => const Center(
        child: CupertinoActivityIndicator(),
      );

  Widget imageView(KaigaAsset asset) => Center(
        child: AssetEntityImage(asset.entity),
      );

  Widget get videoView => Center(
        child: controller != null
            ? AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: VideoPlayer(controller!),
              )
            : loadingView,
      );
}
