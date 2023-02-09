part of pinata;

/// ## Pinata Slug
/// Pinata API Key complete details with both [serial],
/// [userID] and API [key]. This class has cannot
/// interact with Pinata cloud gateway. In order to
/// access Pinata api key interface ie. [_PinataAPI],
/// use [PinataKey.api].
/// <br/><br/>
///
/// ```dart
///   final slug = (await pinata.keys).first;
/// ```
class PinataKey {
  //...Fields
  /// Key unique serial identity.
  final String serial;

  /// Key display name for log purposes.
  final String name;

  /// The actual string that points to this key
  final String key;

  /// Pinata secret key - more like password
  final String secret;

  /// Pinata JWT -  direct authorization crypto string
  final String jWT;

  /// Pinata api key user's serial identity
  final String userID;

  /// List of access granted to this key during it's
  /// creation.
  final List<KeyAccess> access;

  /// DateTime when this key was created. If null,
  /// then this key does not exist.
  final DateTime? createdAt;

  /// DateTime when this key was last updated. if
  /// null, then this key has never been edited
  /// since it's creation.
  final DateTime? updatedAt;

  /// Key revoke status. Determine whether key has
  /// been revoked or not.
  final bool revoked;

  /// Maximum number of usage assigned to this key
  final int? maxUses;

  /// Current key usage count.
  final int uses;

  PinataKey._({
    required this.serial,
    required this.name,
    required this.key,
    required this.secret,
    required this.jWT,
    required this.userID,
    required this.access,
    required this.createdAt,
    required this.updatedAt,
    required this.revoked,
    required this.maxUses,
    required this.uses,
  });

  factory PinataKey._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return PinataKey._(
      serial: data['id'],
      name: data['name'] ?? 'One time key',
      key: data['key'],
      secret: data['secret'],
      jWT: data['JWT'] ?? '',
      userID: data['user_id'],
      uses: data['uses'],
      revoked: data['revoked'] ?? false,
      maxUses: data['max_uses'],
      access: KeyAccess._fromJson(data['scopes']),
      createdAt: DateTime.tryParse(data['createdAt'] ?? ''),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? ''),
    );
  }

  Map<String, dynamic> _toJson() {
    return {
      'id': serial,
      'name': name,
      'key': key,
      'secret': secret,
      'JWT': jWT,
      'user_id': userID,
      'uses': uses,
      'revoked': revoked,
      'max_uses': maxUses,
      'scopes': access.join(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Parse Pinata key data from string. Work's entirely
  /// seamlessly and without network. This is the undo
  /// call for [PinataKey.toString].
  /// <br/><br/>
  ///
  /// ```dart
  /// var key = Pinata.parse('SOURCE');
  /// ```
  factory PinataKey.parse(String source) {
    source = source.replaceAll(RegExp(r'\s+'), '');
    final validKey = RegExp(r'^PinataKey\((.+)\)$');
    final match = validKey.matchAsPrefix(source);
    final data = json.decode(match?.group(1) ?? '{}');
    return PinataKey._fromJson(data);
  }

  /// Decode [_PinataAPI] from slug. Exposes Pinata
  /// slug to Pinata API Key interface.
  /// <br/><br/>
  ///
  /// ```dart
  ///   final slug = (await pinata.keys).first;
  ///   slug.api.pinFile(File('PATH'));
  /// ```
  Pinata get api {
    //...
    if (jWT.isNotEmpty) {
      return Pinata.viaJWT(jWT: jWT);
    }
    return Pinata.viaPair(
      name: name,
      apiKey: key,
      secret: secret,
    );
  }

  /// Revoke key using [admin] - An admin Pinata API
  /// key. This command cannot be undone.
  /// [Watch out!](Oops) <br/><br/>
  ///
  /// [admin] is required  to have [KeyAccess.admin].
  /// if access is missing, throws [KeyAccessException]
  /// <br/><br/>
  Future<bool> revokeBy(Pinata admin) async {
    //...
    final payload = {"apiKey": key};
    final request = Request(
      'PUT',
      Uri.parse('$APICloudURL/users/revokeApiKey'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ...admin._login,
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
    return true;
  }

  @override
  String toString() {
    return 'PinataKey(${json.encode(_toJson())})';
  }
}
