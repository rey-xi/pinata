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

  @override
  String toString() {
    return 'PinJob(\n'
        '\tserial: $serial,\n'
        '\taddress: $address,\n'
        '\tdateQueued: ${dateQueued.toIso8601String()},\n'
        '\tstatus: ${status.code},\n'
        '\tname: $name,\n'
        '\tmeta: $meta,\n'
        '\thostNodes: $hostNodes,\n'
        '\tpinPolicy: $pinPolicy,\n'
        ')';
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
