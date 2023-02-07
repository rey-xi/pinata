part of pinata;

class Pin {
  //...Fields
  final String _uRL;
  final String name;
  final String slip;
  final String address;
  final DateTime datePinned;
  final DateTime? dateUnpinned;
  final List<dynamic> _regions;
  final Map<String, Object?> _meta;
  final Map<String, String> _anchor;

  const Pin._({
    required this.name,
    required this.slip,
    required this.address,
    required this.datePinned,
    required this.dateUnpinned,
    required List regions,
    Map<String, Object?> meta = const {},
    required Map<String, String> anchor,
  })  : _anchor = anchor,
        _uRL = 'https://api.pinata.cloud',
        _regions = regions,
        _meta = meta;

  factory Pin._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return Pin._(
      name: data['metadata']['name'],
      slip: data['id'],
      address: data['ipfs_pin_hash'],
      datePinned: DateTime.parse(data['date_pinned']),
      dateUnpinned: DateTime.tryParse(data['date_unpinned'] ?? ''),
      meta: _decode(data['metadata']['keyvalues']),
      regions: data['regions'],
      anchor: data['cfx'],
    );
  }

  //...Getters
  String get url => 'https://gateway.pinata.cloud/ipfs/$address';

  Map<String, Object?> get metadata => _meta;

  List<dynamic> get regions => _regions;

  //...Methods
  Future<bool> update({
    String? name,
    Map<String, Object?>? meta,
  }) async {
    //...
    final payload = {
      'ipfsPinHash': address,
      ...({"name": name}),
      "keyvalues": meta?.en ?? _meta.en,
    };
    final request = Request(
      'PUT',
      Uri.parse('$_uRL/pinning/hashMetadata'),
    );
    request.headers.addAll(_anchor);
    request.body = json.encode(payload);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    return true;
  }

  Future<bool> unpin() async {
    //...
    final request = Request(
      'DELETE',
      Uri.parse('$_uRL/pinning/unpin/$address'),
    );
    request.headers.addAll(_anchor);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    return true;
  }

  @override
  String toString() {
    return 'Pin(\n'
        '\tname: $name,\n'
        '\tslip: $slip,\n'
        '\taddress: $address,\n'
        '\tdatePinned: ${datePinned.toIso8601String()},\n'
        '\tdateUnpinned: ${dateUnpinned?.toIso8601String()},\n'
        '\tmeta: ${_meta.en},\n'
        ')';
  }
}

enum PinStatus { all, pinned, unpinned }
