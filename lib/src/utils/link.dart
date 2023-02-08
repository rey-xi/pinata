part of pinata;

class PinLink {
  //...Fields
  final int byteSize;
  final String address;
  final DateTime stamp;
  final bool? isDuplicate;

  PinLink({
    required this.byteSize,
    required this.address,
    required this.stamp,
    this.isDuplicate,
  });

  factory PinLink._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return PinLink(
      byteSize: data['PinSize'],
      address: data['IpfsHash'],
      stamp: DateTime.parse(data['Timestamp']),
      isDuplicate: data['isDuplicate'],
    );
  }

  //...Getters
  get contentURL => '$GatewayCloudURL/ipfs/$address';

  //...Methods
  @override
  String toString() {
    return 'PinLink(\n'
        '\tbyteSize: $byteSize,\n'
        '\taddress: $address,\n'
        '\tstamp: ${stamp.toIso8601String()},\n'
        '\tisDuplicate: ${isDuplicate ?? false},\n'
        ')';
  }
}
