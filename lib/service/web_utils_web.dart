// Web implementation
import 'dart:html' as html;

String createBlobUrl(dynamic bytes) {
  final blob = html.Blob([bytes]);
  return html.Url.createObjectUrlFromBlob(blob);
}
