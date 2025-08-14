// web_download_html.dart
import 'dart:typed_data';
import 'dart:html' as html;

/// Dispara la descarga de [bytes] con nombre [filename] en Flutter Web.
Future<bool> saveBytes(String filename, Uint8List bytes) async {
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor =
      html.AnchorElement(href: url)
        ..download = filename
        ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return true;
}
