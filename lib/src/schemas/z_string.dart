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

  /// min validation
  ///
  /// example:
  /// final min = z.string().min(3, message: "Custom error message");
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

  /// max validation
  ///
  /// example:
  /// final max = z.string().max(3, message: "Custom error message");
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

  /// email validation
  ///
  /// example:
  /// final email = z.string().email(message: "Custom error message");
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

  /// url validation
  ///
  /// example:
  /// final url = z.string().url(message: "Custom error message");
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

  /// length validation
  ///
  /// example:
  /// final length = z.string().length(3, message: "Custom error message");
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

  /// uuid validation
  ///
  /// example:
  /// final uuid = z.string().uuid(message: "Custom error message");
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

  /// cuid validation
  ///
  /// example:
  /// final cuid = z.string().cuid(message: "Custom error message");
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

  /// cuid2 validation
  ///
  /// example:
  /// final cuid2 = z.string().cuid2(message: "Custom error message");
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

  /// regex validation
  ///
  /// example:
  /// final regex = z.string().regex(RegExp(r'^[a-z0-9]{20}$'), message: "Custom error message");
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

  /// endsWith validation
  ///
  /// example:
  /// final endsWith = z.string().endsWith('test', message: "Custom error message");
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

  /// startsWith validation
  ///
  /// example:
  /// final startsWith = z.string().startsWith('test', message: "Custom error message");
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

  /// contains validation
  ///
  /// example:
  /// final contains = z.string().contains('test', message: "Custom error message");
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

  /// datetime validation
  ///
  /// example:
  /// final datetime = z.string().datetime(message: "Custom error message");
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

  /// date validation
  ///
  /// example:
  /// final date = z.string().date(message: "Custom error message"); // (YYYY-MM-DD)
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

  /// time validation
  ///
  /// example:
  /// final time = z.string().time(message: "Custom error message"); // (HH:MM:SS[.SSSSSS])
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
