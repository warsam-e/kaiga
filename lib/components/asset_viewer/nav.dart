import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:kaiga/main.dart';
import 'package:kaiga/manager/format_bytes.dart';
import 'package:material_symbols_icons/symbols.dart';

class AssetViewerNav extends StatefulWidget {
  final ValueNotifier<KaigaAsset?> asset;
  const AssetViewerNav(this.asset, {super.key});

  @override
  AssetViewerNavState createState() => AssetViewerNavState();
}

class AssetViewerNavState extends State<AssetViewerNav> {
  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get top => viewPadding.top;

  final manager = KaigaManager();

  ValueNotifier<KaigaAsset?> get currentAsset => widget.asset;

  KaigaAsset? asset;
  FileStat? stat;

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
    setStat(null);
    currentAsset.value?.assetFile.stat.removeListener(initStat);
  }

  init() {
    reset();
    if (currentAsset.value == null) return;
    setAsset(currentAsset.value!);
    currentAsset.value!.assetFile.stat.addListener(initStat);
    initStat();
  }

  initStat() {
    if (!mounted) return;
    final item = currentAsset.value!.assetFile.stat.value;
    if (item == null) return;
    setStat(item);
  }

  void setAsset(KaigaAsset? asset) => setState(() => this.asset = asset);
  void setStat(FileStat? stat) => setState(() => this.stat = stat);

  @override
  Widget build(BuildContext context) =>
      asset != null ? mainView : const SizedBox();

  Widget get mainView => BlurView(
        child: Container(
          padding: EdgeInsets.only(top: top, left: 20, right: 20, bottom: 20),
          color: CupertinoColors.black.withOpacity(0.7),
          child: asset != null && stat != null
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [titleView(asset!, stat!), refreshView],
                )
              : const SizedBox(),
        ),
      );

  Widget titleView(KaigaAsset asset, FileStat stat) {
    titleText(String text, int minSize, int size,
            {double opacity = 1.0, FontWeight weight = FontWeight.normal}) =>
        AutoSizeText(
          text,
          minFontSize: minSize.toDouble(),
          style: TextStyle(
              color: CupertinoColors.white.withOpacity(opacity),
              fontSize: size.toDouble(),
              fontWeight: weight),
        );

    final dimensions = '${asset.entity.width}x${asset.entity.height}';

    final size = stat.size;
    final date = asset.entity.createDateTime;

    // June 23, 2021
    // 6:00 PM
    final dateStr = Intl().date("MMMM d, y").format(date);
    final timeStr = Intl().date("jm").format(date);

    final type = asset.entity.type.name;
    final fileInfoText =
        "${formatBytes(size.toDouble())} • $dimensions • $type";

    print([asset.entity.width, asset.entity.height]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titleText(dateStr, 15, 18, weight: FontWeight.bold),
        titleText(timeStr, 12, 14, opacity: 0.7),
        const SizedBox(height: 5),
        titleText(fileInfoText, 12, 14, opacity: 0.7),
      ],
    );
  }

  Widget get refreshView => ButtonView(
        const Icon(
          Symbols.refresh_rounded,
          color: CupertinoColors.white,
          size: 30,
        ),
        onPressed: manager.init,
      );
}
