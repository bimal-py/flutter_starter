// Cap every upload's filename stem so picked images (and any long source name)
// don't reach the server as a 60-char temp string. The server appends its own
// unique id, so a short stem is plenty. Shared by the multipart builder and the
// retry interceptor (which rebuilds the FormData) so BOTH paths send the short
// name — otherwise a retried upload (e.g. after a 401 refresh) would leak the
// long temp name.
const int _maxUploadStemLength = 15;

/// The multipart filename to send. Prefers [name] (a short, user-chosen label)
/// over the on-disk basename, which for picked images is a long temp name like
/// `image_picker_<uuid>_compressed.jpg`. Keeps the original extension, reduces
/// the stem to letters and numbers only (no separators), and caps it to
/// [_maxUploadStemLength].
String buildUploadFilename(String path, [dynamic name]) {
  final basename = path.split('/').last;
  final dot = basename.lastIndexOf('.');
  final ext = dot == -1 ? '' : basename.substring(dot);
  final rawStem = (name is String && name.trim().isNotEmpty)
      ? name.trim()
      : (dot == -1 ? basename : basename.substring(0, dot));
  // Letters and numbers only — strip separators and anything unsafe.
  final safeStem = rawStem.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  final capped = safeStem.length > _maxUploadStemLength
      ? safeStem.substring(0, _maxUploadStemLength)
      : safeStem;
  return '${capped.isEmpty ? 'file' : capped}$ext';
}
