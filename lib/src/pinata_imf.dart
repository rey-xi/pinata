part of pinata;

/// ## Pinata Interface
/// The interface for interacting with Pinata API
/// Gateway. Can be used to pin and unpin files and
/// other kinds of data on the IPFS blockchain.
/// <br/><br/>
///
/// IPFS means Interplanetary File System. It's a
/// decentralised storage network for files.
/// <br/><br/>
///
/// Has two major constructors for Pinata gateway
/// auth: **[Pinata.viaPair]** & **[Pinata.viaJWT]**.
/// <br/><br/>
///
/// **[Pinata.test]** - Pinata test interface can be
/// used to access Pinata test node provided by Rey.
/// <br/><br/>
///
/// **[Pinata.testAdmin]** - Pinata admin interface is
/// the default admin node provided by Rey. Use only
/// during test cases.
/// <br/><br/>
///
/// ```dart
/// var pinata = Pinata.viaPair(
///   name: 'Rey Pinata',
///   apiKey: 'API KEY',
///   secret: 'API SECRET',
/// );
/// ```
class PinataImf {
  //...Fields
  final String _uRL;
  final String _name;
  final Map<String, String> _access;

  const PinataImf._({
    required String name,
    required Map<String, String> access,
  })  : _name = name,
        _uRL = 'https://api.pinata.cloud',
        _access = access;

  //...Getters
  Future<Iterable<PinataSlug>> get apiKeys async {
    //...
    final request = Request(
      'GET',
      Uri.parse('$_uRL/users/apiKeys'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ..._access,
    });
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final data = json.decode(response.body);
    final array = data['keys'] as List? ?? [];
    return array.map(PinataSlug._fromJson);
  }

  Future<Iterable<PinJob>> get pinJobs async {
    //...
    const query = '?sort=ASC';
    final response = await get(
      Uri.parse('$_uRL/pinning/pinJobs$query'),
      headers: _access,
    );
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final data = json.decode(response.body);
    final array = data['rows'] as List? ?? [];
    return array.map(PinJob._fromJson);
  }

  Future<Iterable<Pin>> get pins async {
    //...
    final response = await get(
      Uri.parse('$_uRL/data/pinList'
          '?includeCount=false&pageLimit=50'),
      headers: _access,
    );
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    solicit(e) => e..['cfx'] = _access;
    final data = json.decode(response.body);
    final array = data['rows'] as List? ?? [];
    return array.map(solicit).map(Pin._fromJson);
  }

  Future<PinataLog> get log async {
    //...
    final response = await get(
      Uri.parse('$_uRL/data/userPinnedDataTotal'),
      headers: _access,
    );
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final log = json.decode(response.body);
    return PinataLog._fromJson(log);
  }

  //...Methods
  Future<Iterable<PinataSlug>> queryKeys({
    int? offset,
  }) async {
    //...
    final query = '?offset=${offset ?? 0}';
    final request = Request(
      'GET',
      Uri.parse('$_uRL/users/apiKeys/$query'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ..._access,
    });
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final data = json.decode(response.body);
    final array = data['keys'] as List? ?? [];
    return array.map(PinataSlug._fromJson);
  }

  Future<Iterable<Pin>> queryPins({
    String? name,
    String? hash,
    int? limit,
    int? offset,
    int? minByte,
    int? maxByte,
    PinStatus? status,
    bool? includeCount,
    List<PinMetaQuery>? queries,
  }) async {
    //...
    queries ??= <PinMetaQuery>[];
    final quote = '?includeCount=false';
    final nQ = name != null ? '&metadata[name]=$name' : '';
    final hQ = hash != null ? '&hashContains=$hash' : '';
    final plQ = limit != null ? '&pageLimit=$limit' : '';
    final poQ = offset != null ? '&pageOffset=$offset' : '';
    final mnQ = minByte != null ? '&pinSizeMin=$minByte' : '';
    final mxQ = minByte != null ? '&pinSizeMax=$maxByte' : '';
    final pQ = status != null ? '&status=${status.name}' : '';
    final metaQ = queries.map((e) => '$e').join();
    final query = '$quote$hQ$nQ$pQ$mnQ$mxQ$plQ$poQ$metaQ';
    final response = await get(
      Uri.parse('$_uRL/data/pinList$query'),
      headers: _access,
    );
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    solicit(e) => e..['cfx'] = _access;
    final data = json.decode(response.body);
    final array = data['rows'] as List? ?? [];
    return array.map(solicit).map(Pin._fromJson);
  }

  Future<Pin> loadPin(String address) async {
    //...
    final regex = RegExp(r'(https?://)?((gateway\.pinata\.'
        r'cloud/|/)?ipfs|/)?(\w+)'); //...Resolve Address ''
    final hash = regex.matchAsPrefix(address)?.group(4);
    final pins = await queryPins(hash: hash);
    if (pins.isEmpty) {
      throw Exception('Pin not found: Invalid Hash');
    }
    return pins.first;
  }

  Future<PinSlug> pinFile(
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
      Uri.parse('$_uRL/pinning/pinFileToIPFS'),
    );
    final mf = MultipartFile.fromPath("file", file.path);
    request.headers.addAll(_access);
    request.fields.addAll(payload);
    request.files.add(await mf);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final data = json.decode(response.body);
    return PinSlug._fromJson(data);
  }

  Future<PinSlug> pinDirectory(
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
      Uri.parse('$_uRL/pinning/pinFileToIPFS'),
    );
    request.headers.addAll(_access);
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
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final data = json.decode(response.body);
    return PinSlug._fromJson(data);
  }

  Future<PinSlug> pinBytes(
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
      Uri.parse('$_uRL/pinning/pinFileToIPFS'),
    );
    final mf = MultipartFile.fromBytes(
      "file",
      bytes,
      filename: name, // Lol [!]
    );
    request.headers.addAll(_access);
    request.fields.addAll(payload);
    request.files.add(mf);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final data = json.decode(response.body);
    return PinSlug._fromJson(data);
  }

  Future<PinSlug> pinJson({
    required String name,
    required Map<String, Object> map,
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
      Uri.parse('$_uRL/pinning/pinJSONToIPFS'),
      headers: _access,
      body: payload,
    );
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final data = json.decode(response.body);
    return PinSlug._fromJson(data);
  }

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
      Uri.parse('$_uRL/pinning/pinByHash'),
      headers: _access,
      body: payload,
    );
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    return true;
  }

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
      ).toJson(),
    };
    final request = Request(
      'POST',
      Uri.parse('$_uRL/users/generateApiKey'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ..._access,
    });
    request.body = json.encode(payload);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    final data = json.decode(response.body);
    return Pinata.fromJson(data);
  }

  @override
  String toString() => 'Pinata(\n'
      '\tname: $_name,\n'
      '\taccess: $_access,\n'
      ')';
}
