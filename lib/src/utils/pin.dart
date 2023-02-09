part of pinata;

/// ## Pin
/// Pin data. A struct containing a typical
/// pin details. A pin has no constructor,
/// so it can't be created locally. Change
/// pin meta details via [updateMeta] and delete
/// via [unpin].
/// <br/><br/>
///
/// ```dart
/// var pin = await pinata.loadPin('ADDRESS');
/// ```
class Pin {
  //...Fields
  String _name;
  final String serial;
  final String address;
  final DateTime datePinned;
  DateTime? _dateUnpinned;
  final List<dynamic> _regions;
  final Map<String, Object?> _meta;
  final Map<String, String> _anchor;

  Pin._({
    required String name,
    required this.serial,
    required this.address,
    required this.datePinned,
    DateTime? dateUnpinned,
    required List regions,
    Map<String, Object?> meta = const {},
    required Map<String, String> anchor,
  })  : _name = name,
        _anchor = anchor,
        _dateUnpinned = dateUnpinned,
        _regions = regions,
        _meta = meta;

  factory Pin._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return Pin._(
      name: data['metadata']['name'],
      serial: data['id'],
      address: data['ipfs_pin_hash'],
      datePinned: DateTime.parse(data['date_pinned']),
      dateUnpinned: DateTime.tryParse(data['date_unpinned'] ?? ''),
      meta: _de(data['metadata']['keyvalues']),
      regions: data['regions'],
      anchor: Map<String, String>.from(data['cfx'] ?? {}),
    );
  }

  /// Parse pin data from string. Work's entirely
  /// seamlessly and without network. This is the undo
  /// call for [Pin.toString].
  /// <br/><br/>
  ///
  /// ```dart
  /// var key = Pinata.parse('SOURCE');
  /// ```
  factory Pin.parse(String source) {
    source = source.replaceAll(RegExp(r'\s+'), '');
    final validKey = RegExp(r'^Pin\((.+)\)$');
    final match = validKey.matchAsPrefix(source);
    final data = json.decode(match?.group(1) ?? '{}');
    return Pin._fromJson(data);
  }

  Map<String, dynamic> _toJson() {
    return {
      'metadata': {
        'name': name,
        'keyvalues': _meta.en,
      },
      'id': serial,
      'ipfs_pin_hash': address,
      'date_pinned': datePinned.toIso8601String(),
      'date_unpinned': dateUnpinned?.toIso8601String() ?? '',
      'regions': regions,
    };
  }

  //...Getters
  String get name => _name;

  List<dynamic> get regions => _regions;

  /// Sync status of pin. A status is synced if it's
  /// vouched or anchored by a valid Pinata API key.
  /// Pins created from [Pin.parse] are not synced
  /// by default. Other Pin constructors create fully
  /// synced pin by default.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return pin.isSynced;
  /// ```
  bool get isSynced => _anchor.isNotEmpty;

  /// Pin status. Always [PinStatus.unpin] unless
  /// [unpin] was the last callback on any rep of
  /// this pin which at such case, [dateUnpinned]
  /// will be null
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return pin.status;
  /// ```
  PinStatus get status => dateUnpinned == null //
      ? PinStatus.pinned
      : PinStatus.unpinned;

  /// The date this pin called [unpin]. Always null
  /// unless [status] is [PinStatus.unpinned] - that
  /// is [unpin] was the last callback on any rep of
  /// this pin.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return pin.dateUnpinned;
  /// ```
  DateTime? get dateUnpinned => _dateUnpinned;

  /// The URL where you can locate your pin content.
  /// Basically follows the format
  /// ```url
  /// https://gateway.pinata.cloud/ipfs/ADDRESS
  /// ```
  String get contentURL {
    return '$GatewayCloudURL/ipfs/$address';
  }

  /// Retrieve String version of content from IPFS via
  /// Pinata Gateway. Recover pin content as plain text.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return await pin.contentJson;
  /// ```
  Future<String> get contentBody async {
    //...
    final response = await get(
      Uri.parse(contentURL),
      headers: _anchor,
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
  Future<Map<String, Object?>> get contentJson async {
    //...
    final q = RegExp(r'^"|"$');
    final response = await get(
      Uri.parse(contentURL),
      headers: _anchor,
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
  Future<Iterable<Object?>> get contentArray async {
    //...
    final data = await contentJson;
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
  Future<Uint8List> get contentBytes async {
    //...
    final response = await get(
      Uri.parse(contentURL),
      headers: _anchor,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    return response.bodyBytes;
  }

  /// Get meta data at [key]. If meta does not
  /// contain [key], null is returned. Consider
  /// using [metaAt] for a better usage xp.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return pin['name_id'];
  /// ```
  Object? operator [](String key) => _meta[key];

  //...Methods
  /// Get meta data at [key]. If meta does not
  /// contain [key] or meta data at [key] is
  /// not of type [T], null is returned.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// return pin['name_id'];
  /// ```
  T? metaAt<T>(String key) {
    final value = this[key];
    return value is T ? value : null;
  }

  /// In order for a pin to successfully interact
  /// with it's remote versions, it has to be in
  /// sync with them. To do so, run [Pin.sync]
  /// [api]. Pins fetched from remote are already
  /// in sync by default
  Future<bool> sync(Pinata api) async {
    //...
    final pin = await api.getPin(address);
    if (pin.serial != serial) return false;
    _anchor
      ..clear()
      ..addAll(api._login);
    return true;
  }

  /// Publish meta changes to local and remote
  /// nodes where pin is hosted on IPFS network.
  /// If successful, pin meta and name will be
  /// updated bot locally and across it's remote
  /// host nodes.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// pin.update(name: 'MY NEW PIN MAME');
  /// ```
  Future<bool> updateMeta({
    String? name, //...name
    Map<String, Object?>? meta,
  }) async {
    //...
    if ((name ?? meta) == null) return false;
    if (!isSynced) return false;
    final meta_ = _meta;
    final name_ = this.name;
    _name = name ?? this.name;
    _meta.addAll(meta ?? {});
    //...
    final payload = {
      "name": _name,
      'ipfsPinHash': address,
      "keyvalues": _meta.en,
    };
    final request = Request(
      'PUT',
      Uri.parse('$APICloudURL/pinning/hashMetadata'),
    );
    request.headers.addAll({
      ..._anchor,
      'Content-Type': 'application/json',
    });
    request.body = json.encode(payload);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      _name = name_;
      (_meta..clear()).addAll(meta_);
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    return true;
  }

  /// Unpin or archive pin. It will still be available
  /// on IPFS network and can be re-pinned via
  /// [_PinataAPI.pinFromAddress] using [address]. If
  /// successful, [dateUnpinned] will be set to when
  /// future returns true.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// pin.unpin();
  /// ```
  Future<bool> unpin() async {
    //...
    if (!isSynced) return false;
    final request = Request(
      'DELETE',
      Uri.parse('$APICloudURL/pinning/unpin/$address'),
    );
    request.headers.addAll(_anchor);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    _dateUnpinned = DateTime.now();
    return true;
  }

  @override
  String toString() {
    return 'Pin(${json.encode(_toJson())})';
  }
}

enum PinStatus { all, pinned, unpinned }
