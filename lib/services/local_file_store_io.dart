import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class LocalFileStore {
  static const bool isSupported = true;

  static Future<String?> getDownloadsDirPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final downloadsDir = Directory('${appDir.path}/downloads');
    if (!await downloadsDir.exists()) {
      await downloadsDir.create(recursive: true);
    }
    return downloadsDir.path;
  }

  static Future<bool> fileExists(String path) => File(path).exists();

  static Future<int> fileLength(String path) => File(path).length();

  static Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<Uri?> writeTempAssetFile(
      String filename, Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final artworkFile = File('${tempDir.path}/$filename');
    if (!await artworkFile.exists()) {
      await artworkFile.writeAsBytes(bytes);
    }
    return Uri.file(artworkFile.path);
  }
}
