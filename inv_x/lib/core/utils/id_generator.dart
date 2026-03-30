import 'package:uuid/uuid.dart';

class IdGenerator {
  IdGenerator._();

  static const _uuid = Uuid();

  /// Generates a random v4 UUID.
  static String generate() => _uuid.v4();

  /// Generates a short ID (first 8 characters of a UUID).
  static String generateShort() => _uuid.v4().substring(0, 8);

  /// Generates a prefixed ID, e.g. "PRD-xxxx-xxxx".
  static String generatePrefixed(String prefix) =>
      '$prefix-${_uuid.v4().substring(0, 8)}';
}
