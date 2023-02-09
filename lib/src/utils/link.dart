part of pinata;

class PinLink {
  //...Fields
  final int byteSize;
  final String address;
  final DateTime stamp;
  final bool? isDuplicate;

  PinLink._({
    required this.byteSize,
    required this.address,
    required this.stamp,
    this.isDuplicate,
  });

  factory PinLink._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return PinLink._(
      byteSize: data['PinSize'],
      address: data['IpfsHash'],
      stamp: DateTime.parse(data['Timestamp']),
      isDuplicate: data['isDuplicate'],
    );
  }

  /// Parse Pin link data from string. Work's entirely
  /// seamlessly and without network. This is the undo
  /// call for [PinLink.toString].
  /// <br/><br/>
  ///
  /// ```dart
  /// var key = Pinata.parse('SOURCE');
  /// ```
  factory PinLink.parse(String source) {
    source = source.replaceAll(RegExp(r'\s+'), '');
    final validKey = RegExp(r'^PinLink\((.+)\)$');
    final match = validKey.matchAsPrefix(source);
    final data = match?.group(1) ?? '';
    return PinLink._(
      address: data.split(',').first.trim(),
      stamp: DateTime.parse(data.split(',')[1].trim()),
      byteSize: 0,
      isDuplicate: false,
    );
  }

  /// Retrieve String version of content from IPFS via
  /// Pinata Gateway. Recover pin content as plain text.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return await pin.contentJson;
  /// ```
  Future<String> fetchBody(Pinata api) async {
    //...
    final response = await get(
      Uri.parse('$GatewayCloudURL/ipfs/$address'),
      headers: api._login,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    return response.body;
  }

  /// Retrieve Json version of content from IPFS via
  /// Pinata Gateway. Recovery callback for [pinJson]
  /// as in [_PinataAPI.pinJson]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return await pin.contentJson;
  /// ```
  Future<Map<String, Object?>> fetchJson(Pinata api) async {
    //...
    final q = RegExp(r'^"|"$');
    final response = await get(
      Uri.parse('$GatewayCloudURL/ipfs/$address'),
      headers: api._login,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    var data = json.decode(response.body);
    if (data is String) {
      data = json.decode(data.replaceAll(q, ''));
    }
    if (data is Map) {
      return Map<String, Object?>.from(_de(data));
    }
    return {};
  }

  /// Retrieve Array version of content from IPFS via
  /// Pinata Gateway. Recovery callback for [pinArray]
  /// as in [_PinataAPI.pinArray]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return await pin.contentArray;
  /// ```
  Future<Iterable<Object?>> fetchArray(Pinata api) async {
    //...
    final data = await fetchJson(api);
    if (data['array*'] != null) {
      return data['array*'] as Iterable;
    }
    return [];
  }

  /// Retrieve bytes version of content from IPFS via
  /// Pinata Gateway. Recovery callback for [pinBytes]
  /// as in [_PinataAPI.pinBytes]. Also applies to files
  /// [_PinataAPI.pinFile] and [_PinataAPI.pinDirectory]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return await pin.contentBytes;
  /// ```
  Future<Uint8List> fetchBytes(Pinata api) async {
    //...
    final response = await get(
      Uri.parse('$GatewayCloudURL/ipfs/$address'),
      headers: api._login,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    return response.bodyBytes;
  }

  //...Methods
  @override
  String toString() {
    return 'PinLink(${'$GatewayCloudURL/ipfs/$address,'}'
        '${stamp.toIso8601String()})';
  }
}
