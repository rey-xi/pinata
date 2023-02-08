part of pinata;

/// ## Pinata Exception
/// Thrown whenever Pinata cloud gateway returns
/// with an error code. In this case, that is code
/// other than **200**. [statusCode] exposes the
/// error code while [reasonPhrase] exposes the
/// reason behind error.
/// <br/><br/>
///
/// ```txt
/// PinataException: (255) Bad network detected
/// ```
class PinataException implements Exception {
  //...Field
  final int statusCode;
  final String? reasonPhrase;

  const PinataException._({
    required this.statusCode,
    this.reasonPhrase,
  });

  String? get overridePhrase {
    return reasonPhrase;
  }

  @override
  String toString() {
    return 'PinataException: ($statusCode)'
        '\t${overridePhrase ?? 'Unknown'}';
  }
}

/// ## Pinata Key Access Exception
/// Thrown when a Pinata key is trying to access
/// Pinata API features beyond it's access scope.
/// [operation] defines the feature where this
/// error was thrown while [missingAccess]
/// represents the access needed for [operation]
/// to be supported
/// <br/><br/>
///
/// ```txt
/// KeyAccessException: (get pins)
///      requires Admin Access
/// ```
class KeyAccessException implements Exception {
  //...Field
  final String operation;
  final KeyAccess missingAccess;

  KeyAccessException._({
    required this.operation,
    required this.missingAccess,
  });

  @override
  String toString() {
    return 'KeyAccessException:\t($operation)'
        ' requires ${missingAccess._name} Access';
  }
}
