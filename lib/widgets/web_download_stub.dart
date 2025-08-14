// web_download_stub.dart
import 'dart:typed_data';

/// Stub para plataformas no Web (se usa el flujo de File/Directory).
Future<bool> saveBytes(String filename, Uint8List bytes) async => false;
