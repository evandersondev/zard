// ISO String Namespace
import '../schemas/schemas.dart';

class Iso {
  /// ISO date validation (YYYY-MM-DD)
  /// Example:
  /// ```dart
  /// final isoDateSchema = z.iso.date();
  /// final value = isoDateSchema.parse('2021-01-01'); // returns value
  /// ```
  ZString date({String? message}) =>
      ZStringImpl(message: message)..isoDate(message: message);

  /// ISO time validation (HH:mm:ss or with milliseconds)
  /// Example:
  /// ```dart
  /// final isoTimeSchema = z.iso.time();
  /// final value = isoTimeSchema.parse('12:30:45'); // returns value
  /// ```
  ZString time({String? message}) =>
      ZStringImpl(message: message)..isoTime(message: message);

  /// ISO datetime validation (ISO 8601)
  /// Example:
  /// ```dart
  /// final isoDatetimeSchema = z.iso.datetime();
  /// final value = isoDatetimeSchema.parse('2021-01-01T12:30:45Z'); // returns value
  /// ```
  ZString datetime({String? message}) =>
      ZStringImpl(message: message)..isoDatetime(message: message);

  /// ISO duration validation (ISO 8601 duration format)
  /// Example:
  /// ```dart
  /// final isoDurationSchema = z.iso.duration();
  /// final value = isoDurationSchema.parse('P1DT2H3M4S'); // returns value
  /// ```
  ZString duration({String? message}) =>
      ZStringImpl(message: message)..isoDuration(message: message);
}
