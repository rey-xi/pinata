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
/// var pin = await pinata.getPin('ADDRESS');
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
  final Map<String, String> _host;

  Pin._({
    required String name,
    required this.serial,
    required this.address,
    required this.datePinned,
    DateTime? dateUnpinned,
    required List regions,
    Map<String, Object?> meta = const {},
    required Map<String, String> host,
  })  : _name = name,
        _host = host,
        _dateUnpinned = dateUnpinned,
        _regions = regions,
        _meta = meta;

  factory Pin._fromJson(data) {
    //...
    final x = DateTime.now();
    final iso1 = data['date_pinned'] ?? '';
    final iso2 = data['date_unpinned'] ?? '';
    assert(data is Map<String, dynamic>);
    //...
    return Pin._(
      name: data['metadata']['name'] ?? 'No name set',
      serial: data['id'] ?? 'invalid',
      address: data['ipfs_pin_hash'] ?? 'invalid',
      datePinned: DateTime.tryParse(iso1) ?? x,
      dateUnpinned: DateTime.tryParse(iso2),
      meta: _de(data['metadata']['keyvalues'] ?? {}),
      regions: data['regions'] ?? [],
      host: Map<String, String>.from(data['cfx'] ?? {}),
    );
  }

  /// Parse pin data from string. Work's entirely
  /// seamlessly and without network. This is the
  /// undo call for [Pin.toString].
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
  /// Pin display name.
  /// <br/><br/>
  /// ***Note***
  /// *Just a mere display name. it's not used for*
  /// *neither pin versioning nor identification.*
  String get name => _name;

  /// Pin regions.
  /// <br/><br/>
  /// This feature is still under development. I'm
  /// collating more information on how it can be
  /// best implemented for easy User and developers'
  /// experience.
  List<dynamic> get regions => _regions;

  /// Sync status of pin. A status is synced if it's
  /// vouched or anchored by a valid Pinata API key.
  /// Pins created from [Pin.parse] are not synced
  /// by default. Other Pin constructors create fully
  /// synced pin by default.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
  /// return pin.isSynced;
  /// ```
  bool get isSynced => _host.isNotEmpty;

  /// Pin status. Always [PinStatus.unpin] unless
  /// [unpin] was the last callback on any rep of
  /// this pin which at such case, [dateUnpinned]
  /// will be null
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
  /// return pin.status;
  /// ```
  PinStatus get status {
    return dateUnpinned == null //
        ? PinStatus.pinned
        : PinStatus.unpinned;
  }

  /// Resolve pin content flow/schema.
  /// A file system simulator that helps to group
  /// bytes into byte sections just as folder is
  /// to files.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
  /// return await pin.skeleton;
  /// ```
  PinSchema get schema {
    final li = metaAt<String>('...skeleton.io');
    return PinSchema._parse(li?.split(',') ?? []);
  }

  /// The date this pin called [unpin]. Always null
  /// unless [status] is [PinStatus.unpinned] - that
  /// is [unpin] was the last callback on any rep of
  /// this pin.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
  /// return pin.dateUnpinned;
  /// ```
  DateTime? get dateUnpinned => _dateUnpinned;

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

  /// Retrieve String version of content from IPFS
  /// via Pinata Gateway. Recover pin content as plain
  /// text. <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
  /// return await pin.contentJson;
  /// ```
  Future<String> get contentBody async {
    //...
    final response = await get(
      Uri.parse(contentURL),
      headers: _host,
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
  /// var pin = await pinata.getPin('ADDRESS');
  /// return await pin.contentJson;
  /// ```
  Future<Map<String, Object?>> get contentJson async {
    //...
    final q = RegExp(r'^"|"$');
    final response = await get(
      Uri.parse(contentURL),
      headers: _host,
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
  /// var pin = await pinata.getPin('ADDRESS');
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

  /// Retrieve bytes details of content from IPFS
  /// via Pinata Gateway. Applies to all pinning
  /// services except [_PinataAPI.pinFromAddress]
  /// in some peculiar cases. Contents are returned
  /// as [PinSchema] which can be be either a
  /// folder or a file Skeleton. <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
  /// return await pin.content;
  /// ```
  Future<PinSchema> get content async {
    //...
    final api = Pinata.login(login: _host);
    return await schema.load(contentURL, api);
  }

  /// Get meta data at [key]. If meta does not
  /// contain [key], null is returned. Consider
  /// using [metaAt] for a better usage xp.
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
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
  /// var pin = await pinata.getPin('ADDRESS');
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
    (_host..clear()).addAll(api._login);
    return true;
  }

  /// Download pin content to [dir]. File is stored
  /// in [dir] path under a sub folder named after
  /// `ipfs-ADDRESS/NAME`. <br/><br/>
  /// ```url
  /// DIRECTORY/ipfs-wr5ndj3yHK8nI08eyJGF8DG/book.png
  /// ```
  Future<Files> downloadTo(Directory dir) async {
    //...
    return await schema.save(address, dir);
  }

  /// Publish meta changes to local and remote
  /// nodes where pin is hosted on IPFS network.
  /// If successful, pin meta and name will be
  /// updated bot locally and across it's remote
  /// host nodes. <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
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
      ..._host,
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
  /// future returns true. <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.getPin('ADDRESS');
  /// pin.unpin();
  /// ```
  Future<bool> unpin() async {
    //...
    if (!isSynced) return false;
    final request = Request(
      'DELETE',
      Uri.parse('$APICloudURL/pinning/unpin/$address'),
    );
    request.headers.addAll(_host);
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

/// ## Pin Status
/// Whether a pin is currently pinned or unpinned
/// Also used by Pinata api keys to query pins and
/// pin jobs. See [_PinataAPI.queryPins]
/// <br/><br/>
///
/// ```dart
/// var pinStatus = PinStatus.all;
/// ```
enum PinStatus {
  //...Enumerations
  /// Applicable only in query usage of this api.
  /// Queries all available pins. Both pinned and
  /// unpinned
  all('all'),

  /// Signifies that a pin is currently pinned ie.
  /// [Pin.dateUnpinned] is null. See [Pin.status]
  /// <br/><br/>
  /// Queries all pinned pins when used in Pinata api
  /// [_PinataAPI.queryPins].
  pinned('pinned'),

  /// Signifies that a pin is currently pinned ie.
  /// [Pin.dateUnpinned] is non null. See [Pin.status]
  /// <br/><br/>
  /// Queries all unpinned pins when used in Pinata api
  /// [_PinataAPI.queryPins].
  unpinned('unpinned');

  //...Fields
  final String code;

  const PinStatus(this.code);

  @override
  String toString() => code;
}
