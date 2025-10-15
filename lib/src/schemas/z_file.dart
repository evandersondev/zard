import 'dart:io';

import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class ZFile extends Schema<File> {
  int? _minSize;
  int? _maxSize;
  List<String>? _mimeTypes;

  ZFile({String? message}) {
    addValidator((File file) {
      final fileSize = file.lengthSync();

      // Valida tamanho mínimo
      if (_minSize != null && fileSize < _minSize!) {
        return ZardIssue(
          message: message ?? 'File size must be at least $_minSize bytes',
          type: 'min_size_error',
          value: file,
        );
      }

      // Valida tamanho máximo
      if (_maxSize != null && fileSize > _maxSize!) {
        return ZardIssue(
          message: message ?? 'File size must be at most $_maxSize bytes',
          type: 'max_size_error',
          value: file,
        );
      }

      // Valida tipos MIME
      if (_mimeTypes != null) {
        final mimeType = _getMimeType(file);
        if (mimeType == null || !_mimeTypes!.contains(mimeType)) {
          return ZardIssue(
            message: message ??
                'File MIME type must be one of ${_mimeTypes!.join(", ")}',
            type: 'mime_type_error',
            value: file,
          );
        }
      }

      return null;
    });
  }

  /// Define o tamanho mínimo do arquivo em bytes.
  ZFile min(int size) {
    _minSize = size;
    return this;
  }

  /// Define o tamanho máximo do arquivo em bytes.
  ZFile max(int size) {
    _maxSize = size;
    return this;
  }

  /// Define os tipos MIME permitidos.
  ZFile mime(dynamic types) {
    if (types is String) {
      _mimeTypes = [types];
    } else if (types is List<String>) {
      _mimeTypes = types;
    } else {
      throw ArgumentError('MIME types must be a String or List<String>');
    }
    return this;
  }

  /// Obtém o tipo MIME do arquivo.
  String? _getMimeType(File file) {
    // Aqui você pode usar uma biblioteca como `mime` para determinar o tipo MIME.
    // Exemplo:
    // import 'package:mime/mime.dart';
    // return lookupMimeType(file.path);
    return null; // Substitua por uma implementação real.
  }

  @override
  String toString() {
    return 'ZFile(minSize: $_minSize, maxSize: $_maxSize, mimeTypes: $_mimeTypes)';
  }
}

class ZFileImpl extends ZFile {
  ZFileImpl({super.message});
}
