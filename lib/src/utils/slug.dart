part of pinata;

class PinSlug {
  //...Fields
  final int byteSize;
  final String address;
  final DateTime stamp;
  final bool? isDuplicate;

  PinSlug({
    required this.byteSize,
    required this.address,
    required this.stamp,
    this.isDuplicate,
  });

  factory PinSlug._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return PinSlug(
      byteSize: data['PinSize'],
      address: data['IpfsHash'],
      stamp: DateTime.parse(data['Timestamp']),
      isDuplicate: data['isDuplicate'],
    );
  }

  //...Getters
  get url => 'https://gateway.pinata.cloud/ipfs/$address';

  //...Methods
  @override
  String toString() {
    return 'PinSlug(\n'
        '\tbyteSize: $byteSize,\n'
        '\taddress: $address,\n'
        '\tstamp: ${stamp.toIso8601String()},\n'
        '\tisDuplicate: ${isDuplicate ?? false},\n'
        ')';
  }
}
