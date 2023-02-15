part of pinata;

/// ## Pin Link
/// Pin link. A struct containing a typical
/// pin detail abstract. A link has no definite
/// constructor, so it can't be created locally.
/// Pin Metas are returned during [KeyAccess.pinning]
/// dependent services. Get [Pin] from [PinLink] via
/// [PinLink.load].
/// <br/><br/>
///
/// ```dart
/// var pin = await pinata.loadPin('ADDRESS');
/// ```
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
    final x = DateTime.now();
    final iso = data['Timestamp'] ?? '';
    assert(data is Map<String, dynamic>);
    //...
    return PinLink._(
      byteSize: data['PinSize'] ?? 0,
      address: data['IpfsHash'] ?? 'invalid',
      stamp: DateTime.tryParse(iso) ?? x,
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
    //...
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

  //...Getters
  /// The URL where you can locate your pin content.
  /// Basically follows the format
  /// ```url
  /// https://gateway.pinata.cloud/ipfs/ADDRESS
  /// ```
  String get contentURL {
    //...
    if (Pinata._gatewayID == null) {
      return '$GatewayCloudURL/ipfs/$address';
    }
    return '$DedicatedGatewayURL/ipfs/$address';
  }

  //...Methods
  /// Retrieve String version of content from IPFS via
  /// Pinata Gateway. Recover pin content as plain text.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return await pin.contentJson;
  /// ```
  Future<Pin> load(Pinata api) => api.getPin(address);

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
      Uri.parse(contentURL),
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
      Uri.parse(contentURL),
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

  @override
  String toString() {
    return 'PinLink(${'$GatewayCloudURL/ipfs/$address,'}'
        '${stamp.toIso8601String()})';
  }
}
