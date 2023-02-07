part of pinata;

class PinJob {
  final String slip;
  final String address;
  final DateTime dateQueued;
  final String status;
  final String name;
  final Map<String, Object?> meta;
  final List<dynamic> hostNodes;
  final String pinPolicy;

  PinJob._({
    required this.slip,
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
      slip: data['id'],
      status: data['status'],
      name: data['name'] ?? '',
      address: data['ipfs_pin_hash'],
      dateQueued: DateTime.parse(data['date_queued']),
      meta: data['keyvalues']?.de ?? {},
      hostNodes: data['host_nodes'] ?? [],
      pinPolicy: data['pin_policy'] ?? '',
    );
  }
}
