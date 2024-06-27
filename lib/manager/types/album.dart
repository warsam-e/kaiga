import 'package:flutter/cupertino.dart';
import 'package:kaiga/main.dart';
import 'package:photo_manager/photo_manager.dart';

class KaigaAlbum {
  final String name;
  final AssetPathEntity entity;
  final List<KaigaAsset> assets;
  final ValueNotifier<KaigaAsset?> mainAsset;

  const KaigaAlbum({
    required this.name,
    required this.entity,
    required this.assets,
    required this.mainAsset,
  });

  KaigaManager get manager => KaigaManager();

  static Future<KaigaAlbum> fromEntity(AssetPathEntity entity) async {
    final assets = <KaigaAsset>[];
    KaigaAsset? mainAsset;

    final count = await entity.assetCountAsync;

    if (count > 0) {
      final list = await entity.getAssetListPaged(page: 0, size: count);
      final all = list.map(KaigaAsset.fromAsset).toList();
      assets.addAll(all);
      assets.sort(
          (a, b) => b.entity.createDateTime.compareTo(a.entity.createDateTime));
      mainAsset = await assets.firstOrNull?.init();
    }

    return KaigaAlbum(
      name: entity.name,
      entity: entity,
      assets: assets,
      mainAsset: ValueNotifier(mainAsset),
    );
  }

  add(KaigaAsset asset) async {
    final res = await PhotoManager.editor
        .copyAssetToPath(asset: asset.entity, pathEntity: entity);
    if (res == null) return;
    assets.add(KaigaAsset.fromAsset(res));
    assets.sort(
        (a, b) => b.entity.createDateTime.compareTo(a.entity.createDateTime));
    mainAsset.value = await assets.firstOrNull?.init();
    manager.list.remove(asset);
  }
}
