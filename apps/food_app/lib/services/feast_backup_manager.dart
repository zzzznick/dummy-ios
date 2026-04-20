import 'dart:io';

import 'package:path/path.dart' as p;

import '../storage/app_paths.dart';

class FeastBackupManager {
  FeastBackupManager({AppPaths? paths}) : _paths = paths ?? AppPaths();

  final AppPaths _paths;

  Future<File> _feastFile() async {
    final docs = await _paths.documentsDir();
    return File(p.join(docs, 'feasts.json'));
  }

  Future<Directory> _backupDir() async {
    final docs = await _paths.documentsDir();
    return Directory(p.join(docs, 'backup'));
  }

  Future<File> _backupFile() async {
    final dir = await _backupDir();
    return File(p.join(dir.path, 'feast.backup'));
  }

  Future<bool> hasBackup() async => (await _backupFile()).exists();

  Future<void> backup() async {
    final src = await _feastFile();
    if (!await src.exists()) return;
    final dest = await _backupFile();
    await dest.parent.create(recursive: true);
    await src.copy(dest.path);
  }

  Future<void> restoreIfPresent() async {
    final backup = await _backupFile();
    if (!await backup.exists()) return;
    final dest = await _feastFile();
    await dest.parent.create(recursive: true);
    await backup.copy(dest.path);
  }
}
