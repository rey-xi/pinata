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

  /// Parse Pinata log data from string. Work's entirely
  /// seamlessly and without network. This is the undo
  /// call for [PinataLog.toString].
  /// <br/><br/>
  ///
  /// ```dart
  /// var key = Pinata.parse('SOURCE');
  /// ```
  factory PinataLog.parse(String source) {
    source = source.replaceAll(RegExp(r'\s+'), '');
    final validKey = RegExp(r'^PinataLog\((.+)\)$');
    final match = validKey.matchAsPrefix(source);
    final data = json.decode(match?.group(1) ?? '{}');
    return PinataLog._fromJson(data);
  }

  Map<String, dynamic> _toJson() {
    return {
      'pin_count': count,
      'pin_size_total': debunkSize,
      'pin_size_with_replications_total': totalSize,
    };
  }

  @override
  String toString() {
    return 'PinataLog(${json.encode(_toJson())})';
  }
}
