import 'package:kaiga/main.dart';
import 'package:photo_manager/photo_manager.dart';

class KaigaAlbum {
  final String name;
  final AssetPathEntity entity;
  final KaigaAsset? mainAsset;

  const KaigaAlbum({
    required this.name,
    required this.entity,
    required this.mainAsset,
  });

  static Future<KaigaAlbum> fromEntity(AssetPathEntity entity) async {
    final list = await entity.getAssetListPaged(page: 0, size: 1);
    final main = list.firstOrNull;
    final mainAsset = main != null ? KaigaAsset.fromAsset(main).init() : null;

    return KaigaAlbum(
      name: entity.name,
      entity: entity,
      mainAsset: mainAsset,
    );
  }
}
