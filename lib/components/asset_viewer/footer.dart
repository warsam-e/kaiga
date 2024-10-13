import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaiga/main.dart';
import 'package:material_symbols_icons/symbols.dart';

/// The footer portion of the AssetViewer widget in the Kaiga app.
///
/// This handles the display of the album selection, the favourite and delete buttons.
class AssetViewerFooter extends StatefulWidget {
  final ValueNotifier<KaigaAsset?> asset;
  const AssetViewerFooter(this.asset, {super.key});

  @override
  AssetViewerFooterState createState() => AssetViewerFooterState();
}

class AssetViewerFooterState extends State<AssetViewerFooter> {
  final manager = KaigaManager();

  ValueNotifier<KaigaAsset?> get currentAsset => widget.asset;

  KaigaAsset? asset;

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
    setAsset(null);
  }

  init() async {
    reset();
    if (currentAsset.value == null) return;
    setAsset(currentAsset.value!);
  }

  void setAsset(KaigaAsset? asset) => setState(() => this.asset = asset);

  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get bottom => viewPadding.bottom;

  selectAlbum(KaigaAlbum album) {
    if (asset == null) return;
    album.add(asset!);
  }

  delete() async {
    if (asset == null) return;
    if (await asset!.delete()) reset();
  }

  ButtonView footerActionButton(
    IconData icon, {
    required VoidCallback onPressed,
    Color color = CupertinoColors.white,
  }) =>
      ButtonView(
        Icon(icon, color: color, size: 50),
        onPressed: onPressed,
      );

  @override
  Widget build(BuildContext context) =>
      asset != null ? mainView : const SizedBox();

  Widget get mainView => Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlurView(
          child: Container(
              height: 230,
              padding: EdgeInsets.only(bottom: bottom, top: 20),
              color: CupertinoColors.black.withOpacity(0.7),
              child: Column(
                children: [
                  Expanded(
                    child: asset != null ? albumView(asset!) : const SizedBox(),
                  ),
                  const SizedBox(height: 30),
                  actionRow,
                ],
              )),
        ),
      );

  Widget albumView(KaigaAsset asset) => ListenableView(
        manager.albums,
        builder: (albums) => ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const SizedBox(width: 20),
            for (final album in albums) ...[
              ButtonView(
                albumItemView(album),
                onPressed: () => selectAlbum(album),
              ),
              const SizedBox(width: 20),
            ]
          ],
        ),
      );

  Widget albumItemView(KaigaAlbum album) {
    final radius = BorderRadius.circular(12);
    final placeholderImage = Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.2),
        borderRadius: radius,
      ),
    );

    final albumNameView = AutoSizeText(
      album.name,
      maxLines: 1,
      minFontSize: 12,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.white),
    );

    Widget albumCoverFileView(File file) => Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        );

    final albumCoverView = ListenableView(
      album.mainAsset,
      builder: (mainAsset) => mainAsset != null
          ? ListenableView(
              mainAsset.assetFile.file,
              builder: (file) =>
                  file != null ? albumCoverFileView(file) : placeholderImage,
            )
          : placeholderImage,
    );

    return SizedBox(
      height: 110,
      width: 80,
      child: Column(
        children: [
          albumNameView,
          const SizedBox(height: 5),
          Expanded(
            child: albumCoverView,
          ),
        ],
      ),
    );
  }

  Widget get actionRow => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          favouriteButton,
          const SizedBox(width: 40),
          deleteButton,
        ],
      );

  Widget get favouriteButton => asset != null
      ? ListenableView(
          asset!.isFavourite,
          builder: (isFavourite) => footerActionButton(
            isFavourite ? Icons.favorite_rounded : Symbols.favorite_rounded,
            onPressed: asset!.favourite,
            color:
                isFavourite ? CupertinoColors.systemRed : CupertinoColors.white,
          ),
        )
      : const SizedBox();

  Widget get deleteButton => footerActionButton(
        Symbols.delete_rounded,
        onPressed: delete,
      );
}
