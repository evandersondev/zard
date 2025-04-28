import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

class ZString extends Schema<String> {
  final String? message;

  ZString({this.message}) {
    addValidator((String? value) {
      if (value == null) {
        return ZardIssue(
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
  /// final minSchema = z.string().min(3);
  /// final name = minSchema.parse('John'); // returns 'John'
  /// final name = minSchema.parse('Jo'); // throws with error details
  /// ```
  ZString min(int length, {String? message}) {
    addValidator((String? value) {
      if (value != null && value.length < length) {
        return ZardIssue(
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
  /// final maxSchema = z.string().max(10);
  /// final name = maxSchema.parse('short'); // returns 'short'
  /// final name = maxSchema.parse('this string is too long'); // throws with error details
  /// ```
  ZString max(int length, {String? message}) {
    addValidator((String? value) {
      if (value != null && value.length > length) {
        return ZardIssue(
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
  /// final emailSchema = z.string().email();
  /// final email = emailSchema.parse('john@example.com'); // returns 'john@example.com'
  /// final email = emailSchema.parse('john@example'); // throws with error details
  /// ```
  ZString email({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegExp.hasMatch(value)) {
          return ZardIssue(
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
  /// final urlSchema = z.string().url();
  /// final url = urlSchema.parse('https://www.example.com'); // returns the URL
  /// final url = urlSchema.parse('www.example.com'); // throws with error details
  /// ```
  ZString url({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final urlRegExp = RegExp(
          r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w\.-]*)*\/?$',
        );
        if (!urlRegExp.hasMatch(value)) {
          return ZardIssue(
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

  /// Length validation (exact length)
  /// Example:
  /// ```dart
  /// final lengthSchema = z.string().length(5);
  /// final value = lengthSchema.parse('Hello'); // returns 'Hello'
  /// final value = lengthSchema.parse('Hi'); // throws with error details
  /// ```
  ZString length(int length, {String? message}) {
    addValidator((String? value) {
      if (value != null && value.length != length) {
        return ZardIssue(
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
  /// final uuidSchema = z.string().uuid();
  /// final uuid = uuidSchema.parse('123e4567-e89b-12d3-a456-426614174000'); // returns valid uuid
  /// final uuid = uuidSchema.parse('invalid-uuid'); // throws with error details
  /// ```
  ZString uuid({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final uuidRegExp = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        );
        if (!uuidRegExp.hasMatch(value)) {
          return ZardIssue(
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
  /// final cuidSchema = z.string().cuid();
  /// final cuid = cuidSchema.parse('abcdefghijklmnopqrst'); // returns valid cuid
  /// final cuid = cuidSchema.parse('short'); // throws with error details
  /// ```
  ZString cuid({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final cuidRegExp = RegExp(r'^[a-z0-9]{20}$');
        if (!cuidRegExp.hasMatch(value)) {
          return ZardIssue(
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
  /// final cuid2Schema = z.string().cuid2();
  /// final cuid2 = cuid2Schema.parse('abcdefghijklmnopqrstuvwxxy'); // returns valid cuid2
  /// final cuid2 = cuid2Schema.parse('invalid'); // throws with error details
  /// ```
  ZString cuid2({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final cuid2RegExp = RegExp(r'^[a-z0-9]{24}$');
        if (!cuid2RegExp.hasMatch(value)) {
          return ZardIssue(
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
  /// final regexSchema = z.string().regex(RegExp(r'^[a-zA-Z]+$'));
  /// final value = regexSchema.parse('John'); // returns 'John'
  /// final value = regexSchema.parse('John123'); // throws with error details
  /// ```
  ZString regex(RegExp regex, {String? message}) {
    addValidator((String? value) {
      if (value != null && !regex.hasMatch(value)) {
        return ZardIssue(
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
  /// final endsWithSchema = z.string().endsWith('test');
  /// final value = endsWithSchema.parse('this is a test'); // returns value
  /// final value = endsWithSchema.parse('no match'); // throws with error details
  /// ```
  ZString endsWith(String suffix, {String? message}) {
    addValidator((String? value) {
      if (value != null && !value.endsWith(suffix)) {
        return ZardIssue(
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
  /// final startsWithSchema = z.string().startsWith('Hello');
  /// final value = startsWithSchema.parse('Hello world'); // returns value
  /// final value = startsWithSchema.parse('World Hello'); // throws with error details
  /// ```
  ZString startsWith(String prefix, {String? message}) {
    addValidator((String? value) {
      if (value != null && !value.startsWith(prefix)) {
        return ZardIssue(
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
  /// final containsSchema = z.string().contains('test');
  /// final value = containsSchema.parse('this is a test'); // returns value
  /// final value = containsSchema.parse('no match here'); // throws with error details
  /// ```
  ZString contains(String substring, {String? message}) {
    addValidator((String? value) {
      if (value != null && !value.contains(substring)) {
        return ZardIssue(
          message: message ?? 'Value must contain $substring',
          type: 'contains_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  /// Datetime validation
  /// Example:
  /// ```dart
  /// final datetimeSchema = z.string().datetime();
  /// final value = datetimeSchema.parse('2021-01-01T12:30:00Z'); // returns value
  /// final value = datetimeSchema.parse('2021-01-01 12:30:00'); // throws with error details
  /// ```
  ZString datetime({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final datetimeRegExp = RegExp(
          r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)((-(\d{2}):(\d{2})|Z)?)$',
        );
        if (!datetimeRegExp.hasMatch(value)) {
          return ZardIssue(
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
  /// final dateSchema = z.string().date();
  /// final value = dateSchema.parse('2021-01-01'); // returns value
  /// final value = dateSchema.parse('2021-01-01T12:30:00'); // throws with error details
  /// ```
  ZString date({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final dateRegExp = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
        if (!dateRegExp.hasMatch(value)) {
          return ZardIssue(
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
  /// final timeSchema = z.string().time();
  /// final value = timeSchema.parse('12:00:00'); // returns value
  /// final value = timeSchema.parse('12:00'); // throws with error details
  /// ```
  ZString time({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final timeRegExp = RegExp(r'^(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)$');
        if (!timeRegExp.hasMatch(value)) {
          return ZardIssue(
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
  String parse(dynamic value) {
    clearErrors();

    if (value is! String) {
      addError(
        ZardIssue(
          message: message ?? 'Expected a string value',
          type: 'type_error',
          value: value,
        ),
      );

      throw ZardError(issues);
    }

    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(
          ZardIssue(message: error.message, type: error.type, value: value),
        );
      }
    }

    if (issues.isNotEmpty) {
      throw ZardError(issues);
    }

    for (final transform in getTransforms()) {
      value = transform(value);
    }

    return value;
  }
}

class ZCoerceString extends Schema<String> {
  ZCoerceString({String? message}) {}

  @override
  String parse(dynamic value) {
    clearErrors();

    try {
      String result = value?.toString() ?? "null";
      for (final transform in getTransforms()) {
        result = transform(result);
      }
      return result;
    } catch (e) {
      addError(ZardIssue(
        message: 'Failed to coerce value to string',
        type: 'coerce_error',
        value: value,
      ));
      throw ZardError(issues);
    }
  }
}
