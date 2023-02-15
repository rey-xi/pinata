part of pinata;

/// ## Pin Job
/// Pending Pin event data. Applies only to pins
/// created via [_PinataAPI.pinFromAddress].
/// <br/><br/>
///
/// ```dart
/// var pin = await pinata.loadPin('ADDRESS');
/// ```
class PinJob {
  final String serial;
  final String address;
  final DateTime dateQueued;
  final PinJobStatus status;
  final String name;
  final Map<String, Object?> meta;
  final List<dynamic> hostNodes;
  final String pinPolicy;

  PinJob._({
    required this.serial,
    required this.address,
    required this.dateQueued,
    required this.status,
    required this.name,
    required this.meta,
    required this.hostNodes,
    required this.pinPolicy,
  });

  factory PinJob._fromJson(data) {
    //...
    final x = DateTime.now();
    final iso = data['date_queued'] ?? '';
    assert(data is Map<String, dynamic>);
    //...
    return PinJob._(
      serial: data['id'] ?? 'invalid',
      status: PinJobStatus.from(data['status']),
      name: data['name'] ?? '',
      address: data['ipfs_pin_hash'],
      dateQueued: DateTime.tryParse(iso) ?? x,
      meta: data['keyvalues']?.de ?? {},
      hostNodes: data['host_nodes'] ?? [],
      pinPolicy: data['pin_policy'] ?? '',
    );
  }

  /// Parse Pin job data from string. Work's entirely
  /// seamlessly and without network. This is the undo
  /// call for [PinJob.toString].
  /// <br/><br/>
  ///
  /// ```dart
  /// var key = Pinata.parse('SOURCE');
  /// ```
  factory PinJob.parse(String source) {
    source = source.replaceAll(RegExp(r'\s+'), '');
    final validKey = RegExp(r'^PinJob\((.+)\)$');
    final match = validKey.matchAsPrefix(source);
    final data = json.decode(match?.group(1) ?? '{}');
    return PinJob._fromJson(data);
  }

  Map<String, dynamic> _toJson() {
    return {
      'id': serial,
      'status': status.code,
      'name': name,
      'ipfs_pin_hash': address,
      'date_queued': dateQueued.toIso8601String(),
      'keyvalues': meta.en ?? {},
      'host_nodes': hostNodes,
      'pin_policy': pinPolicy,
    };
  }

  @override
  String toString() {
    return 'PinJob(\n${json.encode(_toJson())})';
  }
}

/// ## Pin Status
/// Describes a typical 'PinJob` phase status from
/// `Prechecking` to `Searching` then to `Retrieving`.
/// Also contains error phases like `Expired`, and
/// `InvalidObject` among few others.
/// <br/><br/>
///
/// Applicable only to [_PinataAPI.pinFromAddress].
enum PinJobStatus {
  //...Enumerations
  /// Prior pin `searching` starts
  preChecking('prechecking'),

  /// Pinata Cloud Gateway now searching for the most
  /// accessible host node of your Pin
  searching('searching'),

  /// Pinata Cloud Gateway now retrieving your pin
  /// from one of it's valid host nodes.
  retrieving('retrieving'),

  /// Pinata Cloud Gateway has stopped pinning as
  /// pinning timeout has been exceeded - 1 day.
  expired('expired'),

  /// Pinata Cloud Gateway stopped pinning as more
  /// pins requires a paid plan or renewal.
  overFreeLimit('over_free_limit'),

  /// Pinata Cloud Gateway stopped pinning because
  /// you've exceeded your pin quota.
  overMaxSize('over_max_size'),

  /// Pinata Cloud could not locate or parse your
  /// specified address
  invalidObject('invalid_object'),

  /// Pinata Cloud could not resolve specified host
  /// nodes.
  badHostNode('bad_host_node');

  //...Fields
  final String code;

  const PinJobStatus(this.code);

  static PinJobStatus from(String? code) {
    return {
      null: PinJobStatus.preChecking,
      'prechecking': PinJobStatus.preChecking,
      'searching': PinJobStatus.searching,
      'retrieving': PinJobStatus.retrieving,
      'expired': PinJobStatus.expired,
      'over_free_limit': PinJobStatus.overFreeLimit,
      'over_max_size': PinJobStatus.overMaxSize,
      'invalid_object': PinJobStatus.invalidObject,
      'bad_host_node': PinJobStatus.badHostNode,
    }[code]!;
  }
}
