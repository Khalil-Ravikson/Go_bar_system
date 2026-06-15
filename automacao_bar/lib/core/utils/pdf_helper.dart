import 'dart:typed_data';
import 'pdf_helper_stub.dart'
    if (dart.library.js_util) 'pdf_helper_web.dart'
    if (dart.library.io) 'pdf_helper_native.dart' as impl;

Future<void> exportAndDownloadPdf(Uint8List bytes, String fileName) async {
  await impl.saveAndLaunchFile(bytes, fileName);
}
