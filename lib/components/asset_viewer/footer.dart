import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaiga/components/utils/disable_child.dart';
import 'package:kaiga/main.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssetViewerFooter extends StatefulWidget {
  final ValueNotifier<KaigaAsset?> asset;
  const AssetViewerFooter(this.asset, {super.key});

  @override
  AssetViewerFooterState createState() => AssetViewerFooterState();
}

class AssetViewerFooterState extends State<AssetViewerFooter> {
  final manager = KaigaManager();

  ValueNotifier<KaigaAsset?> get currentAsset => widget.asset;
  KaigaAlbum? selectedAlbum;

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
    setSelectedAlbum(null);
  }

  init() {
    print("init");
    reset();
    if (currentAsset.value == null) return;
    setAsset(currentAsset.value!);
    print(["init footer", currentAsset.value?.id, manager.albums.value.length]);
  }

  void setSelectedAlbum(KaigaAlbum? album) =>
      setState(() => selectedAlbum = album);
  void setAsset(KaigaAsset? asset) => setState(() => this.asset = asset);

  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get bottom => viewPadding.bottom;

  selectAlbum(KaigaAlbum album) {
    if (album == selectedAlbum) return setSelectedAlbum(null);
    setSelectedAlbum(album);
  }

  continueAction() {
    if (asset != null && selectedAlbum == null) return;
    selectedAlbum!.add(asset!);
    reset();
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
        Icon(icon, color: color, size: 35),
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
              height: 220,
              padding:
                  EdgeInsets.only(bottom: bottom, left: 20, right: 20, top: 20),
              color: CupertinoColors.black.withOpacity(0.7),
              child: Column(
                children: [
                  Expanded(
                    child: asset != null ? albumView(asset!) : const SizedBox(),
                  ),
                  const SizedBox(height: 20),
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
            for (final album in albums) ...[
              ButtonView(
                albumItemView(album),
                onPressed: () => selectAlbum(album),
              ),
              const SizedBox(width: 10),
            ]
          ],
        ),
      );

  Widget albumItemView(KaigaAlbum album) {
    final radius = BorderRadius.circular(15);
    final placeholderImage = Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: CupertinoColors.white.withOpacity(0.2),
        borderRadius: radius,
      ),
    );

    final albumNameView = AutoSizeText(
      album.name,
      maxLines: 1,
      minFontSize: 10,
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

    final albumCoverView = Container(
        decoration: album == selectedAlbum
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: CupertinoColors.activeBlue, width: 3),
              )
            : null,
        child: ListenableView(
          album.mainAsset,
          builder: (mainAsset) => mainAsset != null
              ? ListenableView(
                  mainAsset.assetFile.file,
                  builder: (file) => file != null
                      ? albumCoverFileView(file)
                      : placeholderImage,
                )
              : placeholderImage,
        ));

    return SizedBox(
      width: 90,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          favouriteButton,
          deleteButton,
          continueButton,
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

  Widget get continueButton => DisableChild(
      footerActionButton(
        Symbols.check_rounded,
        onPressed: continueAction,
      ),
      disable: selectedAlbum == null);
}
