import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:kaiga/main.dart';

class AssetViewerFooter extends StatefulWidget {
  final ValueNotifier<KaigaAsset?> asset;
  const AssetViewerFooter(this.asset, {super.key});

  @override
  AssetViewerFooterState createState() => AssetViewerFooterState();
}

class AssetViewerFooterState extends State<AssetViewerFooter> {
  final manager = KaigaManager();

  ValueNotifier<KaigaAsset?> get asset => widget.asset;

  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get bottom => viewPadding.bottom;

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
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlurView(
          child: Container(
            height: 200,
            padding:
                EdgeInsets.only(bottom: bottom, left: 20, right: 20, top: 20),
            color: CupertinoColors.black.withOpacity(0.7),
            child: ListenableView(
              asset,
              builder: (a) => a != null
                  ? Column(
                      children: [
                        Expanded(
                          child: albumView(a),
                        ),
                        const SizedBox(height: 10),
                        actionRow(a),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
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
                onPressed: () => asset.addToAlbum(album),
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

    Widget albumCoverView(File file) => Container(
          decoration: BoxDecoration(
            borderRadius: radius,
            image: DecorationImage(
              image: FileImage(file),
              fit: BoxFit.cover,
            ),
          ),
        );

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          albumNameView,
          const SizedBox(height: 5),
          ...album.mainAsset != null
              ? [
                  Expanded(
                    child: ListenableView(
                      album.mainAsset!.file,
                      builder: (file) => file != null
                          ? albumCoverView(file.file)
                          : placeholderImage,
                    ),
                  )
                ]
              : [placeholderImage],
        ],
      ),
    );
  }

  Widget actionRow(KaigaAsset asset) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          favouriteButton(asset),
          deleteButton(asset),
          const KaigaFilter(),
          keepButton,
        ],
      );

  Widget favouriteButton(KaigaAsset asset) => ListenableView(
        asset.isFavourite,
        builder: (isFavourite) => footerActionButton(
          isFavourite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
          onPressed: asset.favourite,
          color:
              isFavourite ? CupertinoColors.systemRed : CupertinoColors.white,
        ),
      );

  Widget deleteButton(KaigaAsset asset) => footerActionButton(
        CupertinoIcons.trash,
        onPressed: asset.delete,
      );

  Widget get keepButton => footerActionButton(
        CupertinoIcons.checkmark_alt,
        onPressed: manager.next,
      );
}
