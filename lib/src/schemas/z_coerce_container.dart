import 'schemas.dart';

abstract interface class ZCoerce {
  ZCoerceString string() => ZCoerceString();
  ZCoerceDouble double() => ZCoerceDouble();
  ZCoerceBoolean bool() => ZCoerceBoolean();
  ZCoerceNum num() => ZCoerceNum();
  ZCoerceInt int() => ZCoerceInt();
  ZCoerceDate date() => ZCoerceDate();
}

class ZCoerceImpl extends ZCoerce {}
