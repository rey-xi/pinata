part of pinata;

/// ## Pinata API Usage Log
/// Houses every thing there is to know regarding
/// statistics of Pinata IPFS Gateway API usage.
/// <br/><br/>
///
/// ```dart
///   final log = pinata.log.debunkSize;
/// ```
class PinataLog {
  //...Fields
  /// Pinata api key user's total pin count
  /// <br/><br/>
  ///
  /// ```dart
  ///   final log = pinata.log.count;
  /// ```
  final int count;

  /// Pinata api key user's total pin byte
  /// size with duplicate check.
  /// <br/><br/>
  ///
  /// ```dart
  ///   final log = pinata.log.debunkSize;
  /// ```
  final int debunkSize;

  /// Pinata api key user's total pin byte
  /// size without duplicate check.
  /// <br/><br/>
  ///
  /// ```dart
  ///   final log = pinata.log.totalSize;
  /// ```
  final int totalSize;

  const PinataLog._({
    required this.count,
    required this.debunkSize,
    required this.totalSize,
  });

  factory PinataLog._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return PinataLog._(
      count: data['pin_count'],
      debunkSize: data['pin_size_total'],
      totalSize: data['pin_size_with_replications_total'],
    );
  }

  @override
  String toString() {
    return 'PinataLog(\n'
        '\tcount: $count,\n'
        '\tdebunkSize: $debunkSize,\n'
        '\ttotalSize: $totalSize,\n'
        ')';
  }
}
