part of pinata;

/// ## IPFS API Cloud URL
// ignore: constant_identifier_names
const APICloudURL = 'https://api.pinata.cloud';

/// ## IPFS Gateway Cloud URL
// ignore: constant_identifier_names
const GatewayCloudURL = 'https://gateway.pinata.cloud';

/// ## Pinata API KEY
/// The interface for communicating with Pinata IPFS
/// Gateway API. Can be used to pin and unpin files
/// among many other Pinata data, pinning and admin
/// services available on Pinata IPFS Gateway.
/// <br/><br/>
///
/// IPFS means Interplanetary File System. It's a
/// decentralised storage network for files. Only
/// Pinata keys with admin access can use Pinata
/// admin features.
/// <br/><br/>
///
/// See [Pinata] for more Usage cases.
/// ```dart
/// var pinata = Pinata.viaPair(
///   name: 'Rey Pinata',
///   apiKey: 'API KEY',
///   secret: 'API SECRET',
/// );
/// ```
class _PinataAPI {
  //...Fields
  final String _name;
  final Map<String, String> _login;

  const _PinataAPI._({
    required String name,
    required Map<String, String> login,
  })  : _name = name,
        _login = login;

  //...Getters
  /// Fetch all Pinata API keys connected to the user
  /// of this [_PinataAPI]. Returned [apiKeys] is
  /// limited to **10 keys** max *(Pagination)*. Use
  /// [apiKeysAt] to paginate through all available
  /// keys.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.admin].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var keys = await pinata.apiKeys;
  /// ```
  Future<Iterable<PinataKey>> get apiKeys async {
    //...
    final request = Request(
      'GET',
      Uri.parse('$APICloudURL/users/apiKeys'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ..._login,
    });
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    final array = data['keys'] as List? ?? [];
    return array.map(PinataKey._fromJson);
  }

  /// Get a list of all pending pin jobs initiated
  /// by key user. Returned [pinJobs] are sorted in
  /// an ascending order and limited to **5 Jobs**
  /// max *(pagination)*.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.pinJobs]/[KeyAccess.pinning].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var keys = await pinata.pinJobs;
  /// ```
  Future<Iterable<PinJob>> get pinJobs async {
    //...
    const query = '?sort=ASC&limit=5';
    final response = await get(
      Uri.parse('$APICloudURL/pinning/pinJobs$query'),
      headers: _login,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    final array = data['rows'] as List? ?? [];
    return array.map(PinJob._fromJson);
  }

  /// A future list of all successful pins initiated
  /// by key user. Returned [pins] are sorted from
  /// by date pinned from newest till oldest. Result
  /// is limited to **50 pins** max *(Pagination)*
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.pins]/[KeyAccess.data].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var keys = await pinata.pinJobs;
  /// ```
  Future<Iterable<Pin>> get pins async {
    //...
    final response = await get(
      Uri.parse('$APICloudURL/data/pinList'
          '?includeCount=false&pageLimit=50'),
      headers: _login,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    solicit(e) => e..['cfx'] = _login;
    final data = json.decode(response.body);
    final array = data['rows'] as List? ?? [];
    return array.map(solicit).map(Pin._fromJson);
  }

  /// Pinata log of activities on key user's node.
  /// <br/><br/>See [PinataLog] for more details.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.log]/[KeyAccess.data].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var keys = await pinata.log;
  /// ```
  Future<PinataLog> get log async {
    //...
    final response = await get(
      Uri.parse('$APICloudURL/data/userPinnedDataTotal'),
      headers: _login,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final log = json.decode(response.body);
    return PinataLog._fromJson(log);
  }

  //...Methods
  /// Query all Pinata API keys connected to the user
  /// of this [_PinataAPI]. This operation requires
  /// [KeyAccess.admin]. Calling this method without
  /// admin access will throw an exception - [    ]
  /// [PinataException]. Returned [apiKeys] start's
  /// at [offset] and is limited to **10 keys** max
  /// *(Pagination)*. Use [apiKeysAt] to paginate
  /// through all available  keys.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.admin].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var keys = await pinata.apiKeysAt(20);
  /// ```
  Future<List<PinataKey>> apiKeysAt(int offset) async {
    //...
    final query = '?offset=$offset';
    final request = Request(
      'GET',
      Uri.parse('$APICloudURL/users/apiKeys/$query'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ..._login,
    });
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    final array = data['keys'] as List? ?? [];
    return array.map(PinataKey._fromJson).toList();
  }

  /// Fetch a Pin from IPFS Network searching via a
  /// valid [address]. If Address is not valid or no
  /// Pin was found with [address], [PinataException]
  /// will be thrown.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.data] or [KeyAccess.pins].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// ```
  Future<Pin> getPinAt(String address) async {
    //...
    final regex = RegExp(r'(https?://)?((gateway\.pinata\.'
        r'cloud/|/)?ipfs|/)?(\w+)'); //...Resolve Address
    final hash = regex.matchAsPrefix(address)?.group(4);
    final pins = await queryPins(address: hash);
    if (pins.isEmpty || pins.length > 1) {
      throw PinataException._(
        statusCode: 404,
        reasonPhrase: 'Pin not found: '
            '${hash == null ? 'Invalid address' : 'unknown'}',
      );
    }
    return pins.first;
  }

  /// Fetch Pin Job from IPFS Network searching via
  /// a valid [address]. If Address is not valid or no
  /// Pin Job was found with address, [PinataException]
  /// will be thrown.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.data] or [KeyAccess.pins].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.loadPin('ADDRESS');
  /// ```
  Future<PinJob> getPinJobAt(String address) async {
    //...
    final regex = RegExp(r'(https?://)?((gateway\.pinata\.'
        r'cloud/|/)?ipfs|/)?(\w+)'); //...Resolve Address
    final hash = regex.matchAsPrefix(address)?.group(4);
    final pins = await queryPinJobs(address: hash);
    if (pins.isEmpty || pins.length > 1) {
      throw PinataException._(
        statusCode: 404,
        reasonPhrase: 'Pin not found: '
            '${hash == null ? 'Invalid address' : 'unknown'}',
      );
    }
    return pins.first;
  }

  /// Query for a list of all successful and active
  /// pins initiated by key user. Returned [pins] are
  /// sorted from by date pinned from newest to oldest.
  /// Result is limited to [limit] max which default's
  /// to **50 pins** *(Pagination)*. Query by [name],
  /// [address], [minByte], [maxByte], pin [status] and
  /// most importantly meta [queries].
  /// <br/><br/>
  ///
  /// See [PinMetaQuery] to learn how to use [PinMeta]
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.pins]/[KeyAccess.data].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  /// <br/><br/>
  ///
  /// ```dart
  /// var pins = await pinata.queryPins(name: 'ARTs');
  /// ```
  Future<Iterable<Pin>> queryPins({
    String? name,
    String? address,
    int? limit,
    int? offset,
    int? minByte,
    int? maxByte,
    PinStatus? status,
    List<PinMetaQuery>? queries,
  }) async {
    //...
    queries ??= <PinMetaQuery>[];
    if (address != null) {
      final regex = RegExp(r'(https?://)?((gateway\.pinata\.'
          r'cloud/|/)?ipfs|/)?(\w+)'); //...Resolve Address
      address = regex.matchAsPrefix(address)?.group(4);
    }
    final quote = '?includeCount=false';
    final nQ = name != null ? '&metadata[name]=$name' : '';
    final hQ = address != null ? '&hashContains=$address' : '';
    final plQ = limit != null ? '&pageLimit=$limit' : '';
    final poQ = offset != null ? '&pageOffset=$offset' : '';
    final mnQ = minByte != null ? '&pinSizeMin=$minByte' : '';
    final mxQ = minByte != null ? '&pinSizeMax=$maxByte' : '';
    final pQ = status != null ? '&status=${status.name}' : '';
    final metaQ = queries.map((e) => '$e').join();
    final query = '$quote$hQ$nQ$pQ$mnQ$mxQ$plQ$poQ$metaQ';
    final response = await get(
      Uri.parse('$APICloudURL/data/pinList$query'),
      headers: _login,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    solicit(e) => e..['cfx'] = _login;
    final data = json.decode(response.body);
    final array = data['rows'] as List? ?? [];
    return array.map(solicit).map(Pin._fromJson);
  }

  /// Query for a list of all successful and active
  /// pins initiated by key user. Returned [pins] are
  /// sorted from by date pinned from newest to oldest.
  /// Result is limited to [limit] max which default's
  /// to **50 pins** *(Pagination)*. Query by [_name],
  /// [hash], [minByte], [maxByte], pin [status] and
  /// most importantly meta [queries].
  /// <br/><br/>
  ///
  /// See [PinMetaQuery] to learn how to use [PinMeta]
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.pins]/[KeyAccess.data].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  /// <br/><br/>
  ///
  /// ```dart
  /// var pins = await pinata.queryPins(name: 'ARTs');
  /// ```
  Future<Iterable<PinJob>> queryPinJobs({
    bool descending = false,
    PinJobStatus? status,
    String? address,
    int? limit,
    int? offset,
    List<PinMetaQuery>? queries,
  }) async {
    //...
    if (address != null) {
      final regex = RegExp(r'(https?://)?((gateway\.pinata\.'
          r'cloud/|/)?ipfs|/)?(\w+)'); //...Resolve Address
      address = regex.matchAsPrefix(address)?.group(4);
    }
    queries ??= <PinMetaQuery>[];
    final quote = '?sort=${descending ? 'DESC' : 'ASC'}';
    final hQ = address != null ? '&ipfs_pin-hash=$address' : '';
    final plQ = limit != null ? '&pageLimit=$limit' : '';
    final poQ = offset != null ? '&offset=$offset' : '';
    final pQ = status != null ? '&status=${status.code}' : '';
    final metaQ = queries.map((e) => '$e').join();
    final query = '$quote$hQ$pQ$plQ$poQ$metaQ';
    final response = await get(
      Uri.parse('$APICloudURL/pinning/pinJobs$query'),
      headers: _login,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    final array = data['rows'] as List? ?? [];
    return array.map(PinJob._fromJson);
  }

  /// Pin [file] to IPFS Network. Pass in an optional
  /// [name] and [meta]. If name is [null] or is not
  /// provided, [file] name will be used instead.
  /// <br/><br/>.
  ///
  /// Requires [KeyAccess.pinFile]/[KeyAccess.pinning].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.pinFile(File('PATH'));
  /// ```
  Future<PinLink> pinFile(
    File file, {
    String? name,
    Map<String, Object>? meta,
  }) async {
    //...
    name ??= file.uri.pathSegments.last;
    final metadata = {
      "name": name,
      "keyvalues": meta?.en ?? {},
    };
    final payload = {
      'pinataOptions': '{"cidVersion": 1}',
      'pinataMetadata': json.encode(metadata),
    };
    final request = MultipartRequest(
      'POST', //...Pin File to Pinata.
      Uri.parse('$APICloudURL/pinning/pinFileToIPFS'),
    );
    final mf = MultipartFile.fromPath("file", file.path);
    request.headers.addAll(_login);
    request.fields.addAll(payload);
    request.files.add(await mf);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    return PinLink._fromJson(data);
  }

  /// Pin [directory] to IPFS Network. All files in
  /// this directory will be encoded and pinned as
  /// directory subset. Optionally pass in [name]
  ///  and [meta]. If name is null or it's not [ ]
  /// provided, [file] name will be used instead.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.pinFile]/[KeyAccess.pinning].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.pinDirectory(
  ///   Directory('PATH'),
  /// );
  /// ```
  Future<PinLink> pinDirectory(
    Directory directory, {
    String? name,
    Map<String, Object>? meta,
  }) async {
    //...
    name ??= directory.uri.pathSegments.last;
    final metadata = {
      "name": name,
      "keyvalues": meta?.en ?? {},
    };
    final payload = {
      'pinataOptions': '{"cidVersion": 1}',
      'pinataMetadata': json.encode(metadata),
    };
    final request = MultipartRequest(
      'POST',
      Uri.parse('$APICloudURL/pinning/pinFileToIPFS'),
    );
    request.headers.addAll(_login);
    request.fields.addAll(payload);
    directory.list(recursive: true).listen((file) {
      final mf = MultipartFile.fromBytes(
        "file",
        File(file.path).readAsBytesSync(),
        filename: file.path //
            .replaceFirst(directory.parent.path, '')
            .replaceFirst(RegExp(r'^[/\\]'), '')
            .replaceAll(RegExp(r'\\'), '/'),
      );
      request.files.add(mf);
    }).asFuture();
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    return PinLink._fromJson(data);
  }

  /// Pin bytes array encoded from Files to IPFS
  /// Network. All files in this directory will be
  /// encoded and pinned as directory subset.
  /// Optionally pass in [meta]. [name] is required.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.pinFile]/[KeyAccess.pinning].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.pinBytes(
  ///   [....0, 92.39],
  ///   name: 'my bytes',
  /// );
  /// ```
  Future<PinLink> pinBytes(
    Uint8List bytes, {
    required String name,
    Map<String, Object>? meta,
  }) async {
    //...
    final metadata = {
      "name": name,
      "keyvalues": meta?.en ?? {},
    };
    final payload = {
      'pinataOptions': '{"cidVersion": 1}',
      'pinataMetadata': json.encode(metadata),
    };
    final request = MultipartRequest(
      'POST',
      Uri.parse('$APICloudURL/pinning/pinFileToIPFS'),
    );
    final mf = MultipartFile.fromBytes(
      "file",
      bytes,
      filename: name, // Lol [!]
    );
    request.headers.addAll(_login);
    request.fields.addAll(payload);
    request.files.add(mf);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    return PinLink._fromJson(data);
  }

  /// Pin Json or Map<String, Object> to IPFS Network.
  /// Optionally pass in [meta]. [name] is required.
  /// <br/><br/>.
  ///
  /// Requires [KeyAccess.pinJson]/[KeyAccess.pinning].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.pinJson(
  ///   {'zero': 0, 'status': 'done'},
  ///   name: 'my json',
  /// );
  /// ```
  Future<PinLink> pinJson(
    Map<String, Object> map, {
    required String name,
    Map<String, Object>? meta,
  }) async {
    //...
    final metadata = {
      "name": name,
      "keyvalues": meta?.en ?? {},
    };
    final payload = {
      'pinataOptions': '{"cidVersion": 1}',
      'pinataMetadata': json.encode(metadata),
      'pinataContent': json.encode(map.en),
    };
    final response = await post(
      Uri.parse('$APICloudURL/pinning/pinJSONToIPFS'),
      headers: _login,
      body: payload,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    return PinLink._fromJson(data);
  }

  /// Pin Array or Iterable<Object> to IPFS Network.
  /// Optionally pass in [meta]. [name] is required.
  /// <br/><br/>.
  ///
  /// Requires [KeyAccess.pinJson]/[KeyAccess.pinning].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.pinArray(
  ///   [0, 'done'],
  ///   name: 'my array',
  /// );
  /// ```
  Future<PinLink> pinArray(
    Iterable<Object> array, {
    required String name,
    Map<String, Object>? meta,
  }) {
    return pinJson(
      {'array*': array},
      name: name,
      meta: meta,
    );
  }

  /// Pin Object to IPFS Network. If object is Json
  /// or array, [pinJson] and [pinArray] will be used
  /// instead respectively. Optionally pass in [meta].
  /// [name] is required.
  /// <br/><br/>.
  ///
  /// Requires [KeyAccess.pinJson]/[KeyAccess.pinning].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.pinArray(
  ///   [0, 'done'],
  ///   name: 'my array',
  /// );
  /// ```
  Future<PinLink> pinValue(
    Object value, {
    required String name,
    Map<String, Object>? meta,
  }) {
    if (value is Map<String, Object>) {
      return pinJson(
        value,
        name: name,
        meta: meta,
      );
    }
    if (value is Iterable<Object>) {
      return pinArray(
        value,
        name: name,
        meta: meta,
      );
    }
    return pinJson(
      {'value*': value},
      name: name,
      meta: meta,
    );
  }

  /// Pin a file or data that is already encoded en
  /// coded inn English.Optionally pass in [meta].
  /// [name] is required.
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.pinFromAddress]/[KeyAccess.pinning].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var pin = await pinata.pinFromAddress(
  ///   HASH Address
  /// );
  /// ```
  Future<bool> pinFromAddress(
    String address, {
    String? name,
    Map<String, Object>? meta,
  }) async {
    //...
    final regex = RegExp(r'(https?://)?((gateway\.pinata\.'
        r'cloud/|/)?ipfs|/)?(\w+)'); //...Resolve Address
    final hash = regex.matchAsPrefix(address)?.group(4);
    final metadata = {
      ...(name != null ? {"name": name} : {}),
      "keyvalues": meta?.en ?? {},
    };
    final payload = {
      "hashToPin": hash,
      'pinataOptions': '{"cidVersion": 1}',
      'pinataMetadata': json.encode(metadata),
    };
    final response = await post(
      Uri.parse('$APICloudURL/pinning/pinByHash'),
      headers: _login,
      body: payload,
    );
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    return true;
  }

  /// Create new Pinata API Key. Returns a new Pinata
  /// hosting the newly created API key. Key will be
  /// created with [name] and restricted with [access]
  /// <br/><br/>
  ///
  /// Requires [KeyAccess.admin]
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  ///
  /// ```dart
  /// var key = await pinata.createKey(
  ///   name: 'My Key',
  ///   access: [KeyAccess.admin],
  /// );
  /// ```
  Future<Pinata> createKey({
    required String name,
    required List<KeyAccess> access,
    int? maxUses,
  }) async {
    final payload = {
      'keyName': name,
      ...(maxUses != null ? {'maxUses': maxUses} : {}),
      'permissions': KeyAccess._(
        access.map((e) => '$e'),
        'Permissions',
      )._toJson(),
    };
    final request = Request(
      'POST',
      Uri.parse('$APICloudURL/users/generateApiKey'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ..._login,
    });
    request.body = json.encode(payload);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw PinataException._(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
      );
    }
    final data = json.decode(response.body);
    return Pinata._fromJson(data);
  }

  @override
  String toString() => 'PinataAPI(\n'
      '\tname: $_name,\n'
      '\tlogin: $_login,\n'
      ')';
}
