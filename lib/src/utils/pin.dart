part of pinata;

/// ## Pin
/// Pin data. A struct containing a typical
/// pin details. A pin has no constructor,
/// so it can't be created locally. Change
/// pin meta details via [update] and delete
/// via [unpin].
/// <br/><br/>
///
/// ```dart
/// var pin = await pinata.loadPin('ADDRESS');
/// ```
class Pin {
  //...Fields
  String _name;
  final String _uRL;
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
        _uRL = 'https://api.pinata.cloud',
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
      anchor: data['cfx'],
    );
  }

  //...Getters
  String get name => _name;

  List<dynamic> get regions => _regions;

  String get contentURL => '$GatewayCloudURL/ipfs/$address';

  DateTime? get dateUnpinned => _dateUnpinned;

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
  Future<bool> update({
    String? name,
    Map<String, Object?>? meta,
  }) async {
    //...
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
      Uri.parse('$_uRL/pinning/hashMetadata'),
    );
    request.headers.addAll(_anchor);
    request.body = json.encode(payload);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      _name = name_;
      _meta
        ..clear()
        ..addAll(meta_);
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
    final request = Request(
      'DELETE',
      Uri.parse('$_uRL/pinning/unpin/$address'),
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
    return 'Pin(\n'
        '\tname: $name,\n'
        '\tserial: $serial,\n'
        '\taddress: $address,\n'
        '\tdatePinned: ${datePinned.toIso8601String()},\n'
        '\tdateUnpinned: ${dateUnpinned?.toIso8601String()},\n'
        '\tmeta: ${_meta.en},\n'
        ')';
  }
}

enum PinStatus { all, pinned, unpinned }
