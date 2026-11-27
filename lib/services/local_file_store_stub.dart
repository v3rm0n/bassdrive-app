import 'dart:typed_data';

class LocalFileStore {
  static const bool isSupported = false;

  static Future<String?> getDownloadsDirPath() async => null;

  static Future<bool> fileExists(String path) async => false;

  static Future<int> fileLength(String path) async => 0;

  static Future<void> deleteFile(String path) async {}

  static Future<Uri?> writeTempAssetFile(
      String filename, Uint8List bytes) async =>
      null;
}
