import '../types/zart_error.dart';

import 'schemas.dart';

class ZDate extends Schema<DateTime> {
  final String? message;

  ZDate({this.message});

  /// Validates a datetime.
  /// Success:

  ///

  ZDate datetime() {
    addValidator((dynamic value) {
      return _validate(value);
    });

    return this;
  }

  ZardError? _validate(dynamic value) {
    if (value is DateTime) {
      value = value.toIso8601String();
    }

    final dateRegExp = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})$|^(\d{1,2})/(\d{1,2})/(\d{2,4})$|^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)((?:[+-](\d{2}):(\d{2})|Z)?)$',
    );
    if (!dateRegExp.hasMatch(value.toString())) {
      return ZardError(
        message: message ?? 'Invalid datetime format',
        type: 'datetime',
        value: value,
      );
    }

    final date = DateTime.tryParse(value.toString());
    if (date == null) {
      return ZardError(
        message: message ?? 'Invalid datetime format',
        type: 'datetime',
        value: value,
      );
    }

    // Additional checks to ensure the date is valid
    final components = value.toString().split(RegExp(r'[-T:/\.Z+]'));
    if (components.length >= 3) {
      final year = int.parse(components[0]);
      final month = int.parse(components[1]);
      final day = int.parse(components[2]);

      if (year < 1 || month < 1 || month > 12 || day < 1 || day > 31) {
        return ZardError(
          message: message ?? 'Invalid datetime format',
          type: 'datetime',
          value: value,
        );
      }
    }

    return null;
  }

  @override
  DateTime? parse(dynamic value) {
    if (value == null && isOptional) {
      return null;
    }

    final validationResult = _validate(value);
    if (validationResult != null) {
      addError(
        ZardError(
          message: validationResult.message,
          type: validationResult.type,
          value: value,
        ),
      );
      return null;
    }

    if (value is String) {
      try {
        final date = DateTime.parse(value);
        return date;
      } catch (e) {
        addError(
          ZardError(
            message: 'Invalid date format',
            type: 'datetime',
            value: value,
          ),
        );
        return null;
      }
    }
    return super.parse(value) as DateTime;
  }

  @override
  Map<String, dynamic> safeParse(dynamic value, {String fieldName = ''}) {
    try {
      final parsed = parse(value);
      return {'success': true, 'data': parsed};
    } catch (e) {
      return {'success': false, 'errors': getErrors()};
    }
  }
}
