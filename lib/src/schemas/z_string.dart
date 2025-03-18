import '../types/zart_error.dart';

import 'schema.dart';

class ZString extends Schema<String> {
  ZString({String? message}) {
    addValidator((String? value) {
      if (value == null) {
        return ZardError(
          message: message ?? 'Expected a string value',
          type: 'type_error',
          value: value,
        );
      }
      return null;
    });
  }

  /// Min validation
  /// Example:
  /// ```dart
  /// final min = z.string().min(3);
  /// final name = min.parse('John'); // Pass
  /// final name = min.parse('Jo'); // null
  /// ```
  ZString min(int length, {String? message}) {
    addValidator((String? value) {
      if (value != null && value.length < length) {
        return ZardError(
          message: message ?? 'Value must be at least $length characters long',
          type: 'min_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Max validation
  /// Example:
  /// ```dart
  /// final max = z.string().max(3);
  /// final name = max.parse('John'); // Pass
  /// final name = max.parse('Jo'); // Pass
  /// final name = max.parse('Jo'); // null
  /// ```
  ZString max(int length, {String? message}) {
    addValidator((String? value) {
      if (value != null && value.length > length) {
        return ZardError(
          message: message ?? 'Value must be at most $length characters long',
          type: 'max_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Email validation
  /// Example:
  /// ```dart
  /// final email = z.string().email();
  /// final email = email.parse('john@example.com'); // Pass
  /// final email = email.parse('john@example'); // null
  /// ```
  ZString email({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegExp.hasMatch(value)) {
          return ZardError(
            message: message ?? 'Invalid email format',
            type: 'email_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// URL validation
  /// Example:
  /// ```dart
  /// final url = z.string().url();
  /// final url = url.parse('https://www.example.com'); // Pass
  /// final url = url.parse('www.example.com'); // null
  /// ```
  ZString url({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final urlRegExp = RegExp(
          r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
        );
        if (!urlRegExp.hasMatch(value)) {
          return ZardError(
            message: message ?? 'Invalid URL format',
            type: 'url_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Length validation
  /// Example:
  /// ```dart
  /// final length = z.string().length(3);
  /// final name = length.parse('Doe'); // Pass
  /// final name = length.parse('Do'); // null
  /// final name = length.parse('D'); // null
  /// final name = length.parse('John'); // null
  /// ```
  ZString length(int length, {String? message}) {
    addValidator((String? value) {
      if (value != null && value.length != length) {
        return ZardError(
          message: message ?? 'Value must be exactly $length characters long',
          type: 'length_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// UUID validation
  /// Example:
  /// ```dart
  /// final uuid = z.string().uuid();
  /// final uuid = uuid.parse('123e4567-e89b-12d3-a456-426614174000'); // Pass
  /// final uuid = uuid.parse('123e4567-e89b-12d3-a456-42661417400'); // null
  /// final uuid = uuid.parse('123e4567-e89b-12d3-a456-4266141740000'); // null
  /// ```
  ZString uuid({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final uuidRegExp = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        );
        if (!uuidRegExp.hasMatch(value)) {
          return ZardError(
            message: message ?? 'Invalid UUID format',
            type: 'uuid_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// CUID validation
  /// Example:
  /// ```dart
  /// final cuid = z.string().cuid();
  /// final cuid = cuid.parse('123e4567-e89b-12d3-a456-426614174000'); // Pass
  /// final cuid = cuid.parse('123e4567-e89b-12d3-a456-42661417400'); // null
  /// final cuid = cuid.parse('123e4567-e89b-12d3-a456-4266141740000'); // null
  /// ```
  ZString cuid({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final cuidRegExp = RegExp(r'^[a-z0-9]{20}$');
        if (!cuidRegExp.hasMatch(value)) {
          return ZardError(
            message: message ?? 'Invalid CUID format',
            type: 'cuid_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// CUID2 validation
  /// Example:
  /// ```dart
  /// final cuid2 = z.string().cuid2();
  /// final cuid2 = cuid2.parse('123e4567-e89b-12d3-a456-426614174000'); // Pass
  /// final cuid2 = cuid2.parse('123e4567-e89b-12d3-a456-42661417400'); // null
  /// final cuid2 = cuid2.parse('123e4567-e89b-12d3-a456-4266141740000'); // null
  /// ```
  ZString cuid2({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final cuid2RegExp = RegExp(r'^[a-z0-9]{24}$');
        if (!cuid2RegExp.hasMatch(value)) {
          return ZardError(
            message: message ?? 'Invalid CUID2 format',
            type: 'cuid2_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Regex validation
  /// Example:
  /// ```dart
  /// final regex = z.string().regex(RegExp(r'^[a-zA-Z]+$'));
  /// final name = regex.parse('John'); // Pass
  /// final name = regex.parse('123'); // null
  /// ```
  ZString regex(RegExp regex, {String? message}) {
    addValidator((String? value) {
      if (value != null && !regex.hasMatch(value)) {
        return ZardError(
          message: message ?? 'Invalid regex format',
          type: 'regex_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// EndsWith validation
  /// Example:
  /// ```dart
  /// final endsWith = z.string().endsWith('test');
  /// final name = endsWith.parse('John Doe'); // Pass
  /// final name = endsWith.parse('John'); // null
  /// ```
  ZString endsWith(String suffix, {String? message}) {
    addValidator((String? value) {
      if (value != null && !value.endsWith(suffix)) {
        return ZardError(
          message: message ?? 'Value must end with $suffix',
          type: 'ends_with_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// StartsWith validation
  /// Example:
  /// ```dart
  /// final startsWith = z.string().startsWith('John');
  /// final name = startsWith.parse('John Doe'); // Pass
  /// final name = startsWith.parse('Doe'); // null
  /// ```
  ZString startsWith(String prefix, {String? message}) {
    addValidator((String? value) {
      if (value != null && !value.startsWith(prefix)) {
        return ZardError(
          message: message ?? 'Value must start with $prefix',
          type: 'starts_with_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Contains validation
  /// Example:
  /// ```dart
  /// final contains = z.string().contains('test');
  /// final name = contains.parse('test a string'); // Pass
  /// final name = contains.parse('Jane Doe'); // null
  /// ```
  ZString contains(String substring, {String? message}) {
    addValidator((String? value) {
      if (value != null && !value.contains(substring)) {
        return ZardError(
          message: message ?? 'Value must contain $substring',
          type: 'contains_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Date validation
  /// Example:
  /// ```dart
  /// final date = z.string().date();
  /// final date = date.parse('2021-01-01'); // Pass
  /// final date = date.parse('2021-01-01 12:00:00'); // null
  /// ```
  ZString datetime({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final datetimeRegExp = RegExp(
          r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)((-(\d{2}):(\d{2})|Z)?)$',
        );
        if (!datetimeRegExp.hasMatch(value)) {
          return ZardError(
            message: message ?? 'Invalid datetime format',
            type: 'datetime_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Date validation
  /// Example:
  /// ```dart
  /// final date = z.string().date();
  /// final date = date.parse('2021-01-01'); // Pass
  /// final date = date.parse('2021-01-01 12:00:00'); // null
  /// ```
  ZString date({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final dateRegExp = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
        if (!dateRegExp.hasMatch(value)) {
          return ZardError(
            message: message ?? 'Invalid date format',
            type: 'date_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Time validation
  /// Example:
  /// ```dart
  /// final time = z.string().time();
  /// final time = time.parse('12:00:00'); // Pass
  /// final time = time.parse('12:00:00.000'); // null
  /// ```
  ZString time({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final timeRegExp = RegExp(r'^(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)$');
        if (!timeRegExp.hasMatch(value)) {
          return ZardError(
            message: message ?? 'Invalid time format',
            type: 'time_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  @override
  String? parse(dynamic value, {String fieldName = ''}) {
    clearErrors();

    if (value is! String) {
      addError(
        ZardError(
          message: 'Expected a string value',
          type: 'type_error',
          value: value,
        ),
      );
      return null;
    }

    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(
          ZardError(message: error.message, type: error.type, value: value),
        );
      }
    }

    if (errors.isNotEmpty) {
      return null;
    }

    for (final transform in getTransforms()) {
      value = transform(value);
    }

    return value;
  }
}
