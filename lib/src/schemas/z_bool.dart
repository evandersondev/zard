import '../types/zart_error.dart';
import 'schema.dart';

class ZBool extends Schema<bool> {
  ZBool({String? message}) {
    addValidator((value) {
      if (value != true && value != false) {
        addError(
          ZardError(
            message: message ?? 'Expected a boolean value',
            type: 'type_error',
            value: value,
          ),
        );
        return null;
      }
      return null;
    });
  }

  @override
  bool? parse(dynamic value) {
    clearErrors();

    if (value is! bool && value != null) {
      addError(
        ZardError(
          message: 'Expected a boolean value',
          type: 'type_error',
          value: value,
        ),
      );

      return null;
    }
    return value;
  }
}
