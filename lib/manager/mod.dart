import 'dart:async';
import 'package:kaiga/main.dart';
import 'package:photo_manager/photo_manager.dart';

export 'value_notifier_list.dart';
export 'types/mod.dart';

/// The KaigaManager class is a singleton that manages the state of the Kaiga app.
///
/// It has a list of albums and a list of assets, and it initializes them when the app starts.
///
/// It also has a method to get the permission to access the user's photos.
class KaigaManager {
  static final KaigaManager manager = KaigaManager._internal();
  factory KaigaManager() => manager;
  KaigaManager._internal();
  final albums = ValueNotifierList<KaigaAlbum>([]);
  final list = ValueNotifierList<KaigaAsset>([]);

  FutureOr init() async {
    list.value = [];
    albums.value = [];
    if (!(await _getPermission())) {
      await showAlert(
        title: "Permission Denied",
        content:
            "We will send you to the settings app to enable full access to your photos in order for Kaiga to work",
      );
      return PhotoManager.openSetting();
    }
    await initAlbums();
    await initList();
  }

  initAlbums() async {
    albums.value = [];
    final allAlbums = await PhotoManager.getAssetPathList(
      pathFilterOption: const PMPathFilter(
        darwin: PMDarwinPathFilter(type: [PMDarwinAssetCollectionType.album]),
      ),
    );

    albums.value =
        await Future.wait(allAlbums.map(KaigaAlbum.fromEntity).toList());
  }

  initList() async {
    list.value = [];
    final count = await PhotoManager.getAssetCount();
    final allAssets =
        await PhotoManager.getAssetListPaged(page: 0, pageCount: count);
    if (allAssets.isEmpty) return;
    final all = allAssets.map(KaigaAsset.fromAsset).toList();

    final items = <KaigaAsset>[];

    for (final asset in all) {
      final inAlbum =
          albums.value.any((a) => a.assets.any((b) => b.id == asset.id));
      if (!inAlbum) items.add(asset);
    }

    list.value = items;
  }

  Future<bool> _getPermission() =>
      PhotoManager.requestPermissionExtend().then((ps) => ps.isAuth);
}
