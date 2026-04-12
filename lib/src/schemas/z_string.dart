import 'package:string_normalizer/string_normalizer.dart' show StringNormalizer;

import '../types/zard_error.dart';
import '../types/zard_issue.dart';
import 'schema.dart';

abstract interface class ZString extends Schema<String> {
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
  ZString email({String? message, RegExp? pattern}) {
    addValidator((
      String? value,
    ) {
      if (value != null) {
        final emailRegExp = pattern ??
            RegExp(
              r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
              caseSensitive: false,
            );
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
  ///
  /// // Custom hostname and protocol using RegExp
  /// final customSchema = z.string().url(
  ///   hostname: RegExp(r'^[\w\.-]+\.example\.com$'),
  ///   protocol: RegExp(r'^https?:\\/\\/'),
  /// );
  /// final url = customSchema.parse('https://api.example.com/path'); // returns the URL
  /// final url = customSchema.parse('http://other.com'); // throws with error details
  /// ```
  ZString url({String? message, RegExp? hostname, RegExp? protocol}) {
    addValidator((String? value) {
      if (value != null) {
        // Helper to remove start/end anchors from user-supplied patterns so they
        // can be safely embedded into a larger combined pattern.
        String stripAnchors(String p) {
          var s = p;
          s = s.replaceFirst(RegExp(r'^\^+'), '');
          if (s.endsWith(r'$')) {
            s = s.substring(0, s.length - 1);
          }
          return s;
        }

        final protocolPattern = protocol != null
            ? stripAnchors(protocol.pattern)
            : r'(https?:\/\/)?';

        // Build the hostname portion: use custom pattern if provided, otherwise use a permissive default.
        final hostnamePattern = hostname != null
            ? stripAnchors(hostname.pattern)
            : r'([\da-z\.-]+)\.([a-z\.]{2,6})';

        // Remainder of path
        final pathPattern = r'([\/\w\.-]*)*\/?$';

        final urlPattern =
            '^' + protocolPattern + hostnamePattern + pathPattern;

        // Respect case sensitivity from provided patterns when available; default to case-insensitive.
        final caseSensitive =
            protocol?.isCaseSensitive ?? hostname?.isCaseSensitive ?? false;

        final urlRegExp = RegExp(urlPattern, caseSensitive: caseSensitive);

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
  ZString uuid({String? message, String? version}) {
    // supports "v1", "v2", "v3", "v4", "v5", "v6", "v7", "v8"
    // z.uuid({ version: "v4" });

    addValidator((String? value) {
      if (value != null) {
        final uuidRegExp = switch (version) {
          // explicit version checks: ensure the version nibble matches the requested version
          'v1' => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          'v2' => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-2[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          'v3' => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-3[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          'v4' => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          'v5' => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-5[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          'v6' => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-6[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          'v7' => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          'v8' => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-8[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            ),
          // generic: accept any valid UUID version nibble between 1 and 8
          _ => RegExp(
              r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
              caseSensitive: false,
            )
        };
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

  /// UUIDV4 validation
  /// Example:
  /// ```dart
  /// final uuidSchema = z.string().uuid();
  /// final uuid = uuidSchema.parse('123e4567-e89b-12d3-a456-426614174000'); // returns valid uuid
  /// final uuid = uuidSchema.parse('invalid-uuid'); // throws with error details
  /// ```
  ZString uuidv4({String? message}) {
    return uuid(version: 'v4', message: message);
  }

  /// UUIDV6 validation
  /// Example:
  /// ```dart
  /// final uuidSchema = z.string().uuid();
  /// final uuid = uuidSchema.parse('123e4567-e89b-12d3-a456-426614174000') // returns valid uuid
  /// final uuid = uuidSchema.parse('invalid-uuid'); // throws with error details
  /// ```
  ZString uuidv6({String? message}) {
    return uuid(version: 'v6', message: message);
  }

  /// UUIDV7 validation
  /// Example:
  /// ```dart
  /// final uuidSchema = z.string().uuid();
  /// final uuid = uuidSchema.parse('123e4567-e89b-12d3-a456-426614174000') // returns valid uuid
  /// final uuid = uuidSchema.parse('invalid-uuid'); // throws with error details
  /// ```
  ZString uuidv7({String? message}) {
    return uuid(version: 'v7', message: message);
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

  ZString uppercase() {
    addValidator((String? value) {
      if (value != null && value != value.toUpperCase()) {
        return ZardIssue(
          message: message ?? 'Value must be uppercase',
          type: 'uppercase_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  ZString lowercase() {
    addValidator((String? value) {
      if (value != null && value != value.toLowerCase()) {
        return ZardIssue(
          message: message ?? 'Value must be lowercase',
          type: 'lowercase_error',
          value: value,
        );
      }
      return null;
    });
    return this;
  }

  // normalize unicode characters
  ZString normalize() {
    // Full Unicode normalization (NFC) + lightweight cleanups: trim,
    // remove control characters and collapse whitespace.
    addTransform((String value) {
      // Use string_normalizer to remove accents/diacritics and normalize characters.
      var normalized = StringNormalizer.normalize(value);

      // Remove control characters (except common whitespace) that may interfere
      // with comparisons/storage.
      normalized = normalized.replaceAll(
          RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]+'), '');

      // Trim and collapse all whitespace (spaces, tabs, newlines) into single spaces
      normalized = normalized.trim();
      normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

      return normalized;
    });
    return this;
  }

  ZString toUpperCase() {
    addTransform((String value) => value.toUpperCase());
    return this;
  }

  ZString toLowerCase() {
    addTransform((String value) => value.toLowerCase());
    return this;
  }

  ZString trim() {
    addTransform((String value) => value.trim());
    return this;
  }

  /// GUID (UUID v4) validation
  ZString guid({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final guidRegex = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          caseSensitive: false,
        );
        if (!guidRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid GUID format',
            type: 'guid_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// HTTP/HTTPS URL validation
  ZString httpUrl({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final httpUrlRegex = RegExp(
          r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
          caseSensitive: false,
        );
        if (!httpUrlRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid HTTP(S) URL format',
            type: 'http_url_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Hostname validation
  ZString hostname({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final hostnameRegex = RegExp(
          r'^(?!-)[a-zA-Z0-9-]{1,63}(?<!-)(\.[a-zA-Z0-9-]{1,63})*$',
        );
        if (!hostnameRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid hostname format',
            type: 'hostname_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Emoji validation (single emoji)
  ZString emoji({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        // Simplified emoji validation for common emoji ranges
        final emojiRegex = RegExp(
          r'^[\u{1F300}-\u{1F9FF}]$|^[\u{2600}-\u{27BF}]$|^[\u{2300}-\u{23FF}]$|^[\u{2B50}]$|^[\u{1F600}-\u{1F64F}]$',
          unicode: true,
        );
        if (!emojiRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid emoji format',
            type: 'emoji_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Base64 validation
  ZString base64({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
        if (value.isEmpty ||
            !base64Regex.hasMatch(value) ||
            value.length % 4 != 0) {
          return ZardIssue(
            message: message ?? 'Invalid Base64 format',
            type: 'base64_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Base64 URL-safe validation
  ZString base64url({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final base64urlRegex = RegExp(r'^[A-Za-z0-9_-]*$');
        if (value.isEmpty || !base64urlRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid Base64 URL format',
            type: 'base64url_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Hexadecimal validation
  ZString hex({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final hexRegex = RegExp(r'^[0-9a-fA-F]*$');
        if (value.isEmpty ||
            !hexRegex.hasMatch(value) ||
            value.length % 2 != 0) {
          return ZardIssue(
            message: message ?? 'Invalid hexadecimal format',
            type: 'hex_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// JWT validation
  ZString jwt({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final jwtRegex = RegExp(
          r'^eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]*$',
        );
        if (!jwtRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid JWT format',
            type: 'jwt_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Nano ID validation
  ZString nanoid({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final nanoidRegex = RegExp(r'^[V-Za-z0-9_-]{21}$');
        if (!nanoidRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid Nano ID format',
            type: 'nanoid_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// ULID validation
  ZString ulid({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final ulidRegex = RegExp(r'^[0-7][0-9A-HJKMNP-TV-Z]{25}$');
        if (!ulidRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid ULID format',
            type: 'ulid_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// IPv4 validation
  ZString ipv4({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final ipv4Regex = RegExp(
          r'^((25[0-5]|(2[0-4]|1\d?)\d)\.?\b){4}$',
        );
        if (!ipv4Regex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid IPv4 format',
            type: 'ipv4_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// IPv6 validation
  ZString ipv6({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final ipv6Regex = RegExp(
          r'^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))$',
          caseSensitive: false,
        );
        if (!ipv6Regex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid IPv6 format',
            type: 'ipv6_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// MAC address validation
  ZString mac({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final macRegex = RegExp(
          r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
        );
        if (!macRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid MAC address format',
            type: 'mac_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// IPv4 CIDR validation
  ZString cidrv4({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final cidrv4Regex = RegExp(
          r'^((25[0-5]|(2[0-4]|1\d?)\d)\.?\b){4}\/([0-9]|[1-2][0-9]|3[0-2])$',
        );
        if (!cidrv4Regex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid IPv4 CIDR format',
            type: 'cidrv4_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// IPv6 CIDR validation
  ZString cidrv6({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final cidrv6Regex = RegExp(
          r'^(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8])$',
          caseSensitive: false,
        );
        if (!cidrv6Regex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid IPv6 CIDR format',
            type: 'cidrv6_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// Hash validation (sha256, sha1, sha384, sha512, md5)
  ZString hash(String algorithm, {String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final expectedLength = switch (algorithm.toLowerCase()) {
          'sha1' => 40,
          'sha256' => 64,
          'sha384' => 96,
          'sha512' => 128,
          'md5' => 32,
          _ => -1,
        };

        if (expectedLength == -1) {
          return ZardIssue(
            message: message ?? 'Unsupported hash algorithm: $algorithm',
            type: 'hash_error',
            value: value,
          );
        }

        final hashRegex = RegExp(r'^[a-fA-F0-9]+$');
        if (!hashRegex.hasMatch(value) || value.length != expectedLength) {
          return ZardIssue(
            message: message ?? 'Invalid $algorithm hash format',
            type: 'hash_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// ISO date validation (YYYY-MM-DD)
  ZString isoDate({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final isoDateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        if (!isoDateRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid ISO date format (YYYY-MM-DD)',
            type: 'iso_date_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// ISO time validation (HH:mm:ss or with milliseconds)
  ZString isoTime({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final isoTimeRegex = RegExp(r'^\d{2}:\d{2}:\d{2}(\.\d{3})?$');
        if (!isoTimeRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid ISO time format (HH:mm:ss)',
            type: 'iso_time_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// ISO datetime validation (ISO 8601)
  ZString isoDatetime({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final isoDatetimeRegex = RegExp(
          r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z?$',
        );
        if (!isoDatetimeRegex.hasMatch(value)) {
          return ZardIssue(
            message: message ?? 'Invalid ISO datetime format (ISO 8601)',
            type: 'iso_datetime_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  /// ISO duration validation (ISO 8601 duration format)
  ZString isoDuration({String? message}) {
    addValidator((String? value) {
      if (value != null) {
        final isoDurationRegex = RegExp(
          r'^P(\d+Y)?(\d+M)?(\d+W)?(\d+D)?(T(\d+H)?(\d+M)?(\d+(\.\d+)?S)?)?$',
        );
        if (!isoDurationRegex.hasMatch(value)) {
          return ZardIssue(
            message:
                message ?? 'Invalid ISO duration format (e.g., P1DT2H3M4S)',
            type: 'iso_duration_error',
            value: value,
          );
        }
      }
      return null;
    });
    return this;
  }

  @override
  String parse(dynamic value, {String? path}) {
    clearErrors();

    if (value == null) {
      if (isNullable) {
        return null as String;
      }
      addError(
        ZardIssue(
          message: message ?? 'Expected a string value',
          type: 'type_error',
          value: value,
          path: path,
        ),
      );

      throw ZardError(issues);
    }

    if (value is! String) {
      addError(
        ZardIssue(
          message: message ?? 'Expected a string value',
          type: 'type_error',
          value: value,
          path: path,
        ),
      );

      throw ZardError(issues);
    }

    for (final validator in getValidators()) {
      final error = validator(value);
      if (error != null) {
        addError(
          ZardIssue(
            message: error.message,
            type: error.type,
            value: value,
            path: path,
          ),
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

class ZCoerceString extends ZString {
  ZCoerceString({super.message});

  @override
  String parse(dynamic value, {String? path}) {
    clearErrors();

    // Coercion to string is generally safe with toString().
    // We handle null by converting it to an empty string.
    final coercedValue = value?.toString() ?? '';

    // Now, we use the parent's parse method to run all validations.
    return super.parse(coercedValue, path: path);
  }
}

class ZStringImpl extends ZString {
  ZStringImpl({super.message});
}
