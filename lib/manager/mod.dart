import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:kaiga/main.dart';
import 'package:photo_manager/photo_manager.dart';

export 'value_notifier_list.dart';
export 'types/mod.dart';

class KaigaManager {
  static final KaigaManager manager = KaigaManager._internal();
  factory KaigaManager() => manager;
  KaigaManager._internal();
  final albums = ValueNotifierList<KaigaAlbum>([]);
  final all = ValueNotifierList<KaigaAsset>([]);
  final currentAssetId = ValueNotifier<String?>(null);

  FutureOr init() async {
    if (!(await _getPermission())) {
      await showAlert(
        title: "Permission Denied",
        content:
            "We will send you to the settings app to enable full access to your photos in order for Kaiga to work",
      );
      return PhotoManager.openSetting();
    }
    await initAlbums();
    await _initAll();
  }

  initAlbums() async {
    final allAlbums = await PhotoManager.getAssetPathList(
      pathFilterOption: const PMPathFilter(
        darwin: PMDarwinPathFilter(type: [PMDarwinAssetCollectionType.album]),
      ),
    );

    albums.value =
        await Future.wait(allAlbums.map(KaigaAlbum.fromEntity).toList());
  }

  _initAll() async {
    final count = await PhotoManager.getAssetCount();
    final allAssets =
        await PhotoManager.getAssetListPaged(page: 0, pageCount: count);
    if (allAssets.isEmpty) return;
    currentAssetId.value = allAssets.first.id;
    all.value = allAssets.map(KaigaAsset.fromAsset).toList();
  }

  Future<bool> _getPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }

  KaigaAsset? getAsset(String id) {
    final asset =
        all.value.where((element) => element.entity.id == id).firstOrNull;
    if (asset == null) return null;
    return asset.init();
  }

  next() {
    final current = currentAssetId.value;
    if (current == null) return;
    final index =
        all.value.indexWhere((element) => element.entity.id == current);
    if (index == -1) {
      return showAlert(
        title: "Error",
        content: "Something weird happened, restart the app :sob:",
      );
    }

    final nextIndex = index + 1;
    if (nextIndex >= all.value.length) {
      return showAlert(
        title: "End of List",
        content: "You have reached the end of the list",
      );
    }
    currentAssetId.value = all.value[nextIndex].entity.id;
  }

  previous() {
    final current = currentAssetId.value;
    if (current == null) return;
    final index =
        all.value.indexWhere((element) => element.entity.id == current);
    if (index == -1) {
      return showAlert(
        title: "Error",
        content: "Something weird happened, restart the app :sob:",
      );
    }

    final nextIndex = index - 1;
    if (nextIndex < 0) {
      return showAlert(
        title: "Nothing else before this!",
        content: "You have reached the beginning of the list",
      );
    }
    currentAssetId.value = all.value[nextIndex].entity.id;
  }
}
