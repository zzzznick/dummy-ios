import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import '../storage/app_paths.dart';

class ImageStore {
  ImageStore({AppPaths? paths, ImagePicker? picker})
    : _paths = paths ?? AppPaths(),
      _picker = picker ?? ImagePicker();

  final AppPaths _paths;
  final ImagePicker _picker;

  Future<String?> pickAndStoreImage({
    required String id,
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return null;
    return storePickedFile(picked, id: id);
  }

  Future<String> storePickedFile(XFile picked, {required String id}) async {
    final docs = await _paths.documentsDir();
    final imagesDir = Directory(p.join(docs, 'images'));
    await imagesDir.create(recursive: true);

    final ext = p.extension(picked.path).isEmpty
        ? '.jpg'
        : p.extension(picked.path);
    final dest = File(p.join(imagesDir.path, '$id$ext'));
    await File(picked.path).copy(dest.path);
    return dest.path;
  }
}
