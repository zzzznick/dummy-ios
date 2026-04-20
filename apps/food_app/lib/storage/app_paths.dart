import 'package:path_provider/path_provider.dart';

class AppPaths {
  Future<String> documentsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
}
