import 'pdf_helper_stub.dart'
    if (dart.library.js_util) 'pdf_helper_web.dart'
    if (dart.library.io) 'pdf_helper_native.dart' as impl;

abstract class PdfHelper {
  static Future<void> saveAndOpenPdf(List<int> bytes, String filename) {
    return impl.saveAndOpenPdf(bytes, filename);
  }
}
