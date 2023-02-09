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
    assert(data is Map<String, dynamic>);
    return PinJob._(
      serial: data['id'],
      status: _PinJobStatus.from(data['status']),
      name: data['name'] ?? '',
      address: data['ipfs_pin_hash'],
      dateQueued: DateTime.parse(data['date_queued']),
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

enum PinJobStatus {
  preChecking,
  searching,
  retrieving,
  expired,
  overFreeLimit,
  overMaxSize,
  invalidObject,
  badHostNode
}

extension _PinJobStatus on PinJobStatus {
  //...Getters
  String get code => {
        PinJobStatus.preChecking: 'prechecking',
        PinJobStatus.searching: 'searching',
        PinJobStatus.retrieving: 'retrieving',
        PinJobStatus.expired: 'expired',
        PinJobStatus.overFreeLimit: 'over_free_limit',
        PinJobStatus.overMaxSize: 'over_max_size',
        PinJobStatus.invalidObject: 'invalid_object',
        PinJobStatus.badHostNode: 'bad_host_node',
      }[this]!;
  //...Methods
  static PinJobStatus from(String? code) => {
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
