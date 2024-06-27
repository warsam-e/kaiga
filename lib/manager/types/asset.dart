import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:kaiga/main.dart';
import 'package:photo_manager/photo_manager.dart';

class KaigaAssetFile {
  final AssetEntity entity;
  final ValueNotifier<File?> file;
  final ValueNotifier<FileStat?> stat;

  KaigaAssetFile({
    required this.entity,
    required this.file,
    required this.stat,
  });

  factory KaigaAssetFile.fromAsset(AssetEntity asset) => KaigaAssetFile(
        entity: asset,
        file: ValueNotifier(null),
        stat: ValueNotifier(null),
      );

  KaigaAssetFile init() {
    entity.file.then((f) {
      if (f == null) return;
      file.value = f;
      f.stat().then((s) => stat.value = s);
    });
    return this;
  }

  @override
  String toString() => "KaigaAssetFile(\n"
      "  file: $file,\n"
      "  stat: $stat,\n"
      ")";
}

class KaigaAsset {
  final String id;
  AssetEntity entity;
  final KaigaAssetFile assetFile;
  final ValueNotifier<bool> isFavourite;

  KaigaManager get manager => KaigaManager();

  bool inited = false;

  KaigaAsset({
    required this.id,
    required this.entity,
    required this.assetFile,
    required this.isFavourite,
  });

  bool get isImage => entity.type == AssetType.image;
  bool get isVideo => entity.type == AssetType.video;

  factory KaigaAsset.fromAsset(AssetEntity asset) => KaigaAsset(
        id: asset.id,
        entity: asset,
        assetFile: KaigaAssetFile.fromAsset(asset),
        isFavourite: ValueNotifier(asset.isFavorite),
      );

  Future<KaigaAsset> init() async {
    if (inited) return this;
    inited = true;
    assetFile.init();
    return this;
  }

  Future _updateEntity(AssetEntity item) async {
    entity = item;
    isFavourite.value = entity.isFavorite;
  }

  Future favourite() async {
    final res = await PhotoManager.editor.darwin
        .favoriteAsset(entity: entity, favorite: !entity.isFavorite);
    if (res == null) return;
    return _updateEntity(res);
  }

  Future<bool> delete() async {
    if (await PhotoManager.plugin.deleteWithId(entity.id)) {
      manager.list.remove(this);
      return true;
    }
    return false;
  }

  @override
  String toString() => "KaigaAsset(\n"
      "  id: $id,\n"
      "  entity: $entity,\n"
      "  assetFile: $assetFile,\n"
      "  isFavourite: ${isFavourite.value},\n"
      ")";
}
