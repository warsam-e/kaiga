import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:kaiga/main.dart';
import 'package:photo_manager/photo_manager.dart';

class KaigaAssetFile {
  final File file;
  final FileStat stat;

  KaigaAssetFile(this.file, this.stat);

  static Future<KaigaAssetFile?> fromAsset(AssetEntity? asset) async {
    if (asset == null) return null;
    final file = await asset.file;
    if (file == null) return null;

    final stat = await file.stat();

    return KaigaAssetFile(file, stat);
  }

  @override
  String toString() => "KaigaAssetFile(\n"
      "  file: $file,\n"
      "  stat: $stat,\n"
      ")";
}

class KaigaAsset {
  AssetEntity entity;
  final ValueNotifier<KaigaAssetFile?> file;
  final ValueNotifier<bool> isFavourite;

  KaigaManager get manager => KaigaManager();

  bool inited = false;

  KaigaAsset({
    required this.entity,
    required this.file,
    required this.isFavourite,
  });

  bool get isImage => entity.type == AssetType.image;
  bool get isVideo => entity.type == AssetType.video;

  factory KaigaAsset.fromAsset(AssetEntity asset) => KaigaAsset(
        entity: asset,
        file: ValueNotifier(null),
        isFavourite: ValueNotifier(asset.isFavorite),
      );

  KaigaAsset init() {
    if (inited) return this;
    inited = true;
    KaigaAssetFile.fromAsset(entity).then((f) => file.value = f);
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

  Future delete() async {
    if (await PhotoManager.plugin.deleteWithId(entity.id)) {
      manager.next();
      manager.all.remove(this);
    }
  }

  Future addToAlbum(KaigaAlbum album) async {
    final res = await PhotoManager.editor
        .copyAssetToPath(asset: entity, pathEntity: album.entity);
    if (res == null) return;
    await manager.initAlbums();
    return _updateEntity(res);
  }

  @override
  String toString() => "KaigaAsset(\n"
      "  entity: $entity,\n"
      "  file: ${file.value},\n"
      "  isFavourite: ${isFavourite.value},\n"
      ")";
}
