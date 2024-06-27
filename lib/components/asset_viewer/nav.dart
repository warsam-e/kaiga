import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:kaiga/main.dart';
import 'package:kaiga/manager/format_bytes.dart';

class AssetViewerNav extends StatefulWidget {
  final ValueNotifier<KaigaAsset?> asset;
  const AssetViewerNav(this.asset, {super.key});

  @override
  AssetViewerNavState createState() => AssetViewerNavState();
}

class AssetViewerNavState extends State<AssetViewerNav> {
  ValueNotifier<KaigaAsset?> get asset => widget.asset;

  EdgeInsets get viewPadding => MediaQuery.of(context).viewPadding;
  double get top => viewPadding.top;

  final manager = KaigaManager();

  @override
  Widget build(BuildContext context) => BlurView(
      child: Container(
          padding: EdgeInsets.only(top: top, left: 20, right: 20, bottom: 20),
          color: CupertinoColors.black.withOpacity(0.7),
          child: ListenableView(
            asset,
            builder: (a) => a != null
                ? ListenableView(a.file,
                    builder: (file) => file != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [titleView(a, file), goBackButton],
                          )
                        : loadingView)
                : loadingView,
          )));

  Widget titleView(KaigaAsset item, KaigaAssetFile file) {
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

    final dimensions = '${item.entity.width}x${item.entity.height}';

    final size = file.stat.size;
    final date = file.stat.changed;

    // June 23, 2021
    // 6:00 PM
    final dateStr = Intl().date("MMMM d, y").format(date);
    final timeStr = Intl().date("jm").format(date);

    final type = item.entity.type.name;
    final fileInfoText =
        "${formatBytes(size.toDouble())} • $dimensions • $type";

    print([item.entity.width, item.entity.height]);

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

  Widget get goBackButton => ButtonView(
        const Icon(CupertinoIcons.arrow_uturn_left,
            color: CupertinoColors.white, size: 35),
        onPressed: manager.previous,
      );

  Widget get loadingView => const Center(child: CupertinoActivityIndicator());
}
