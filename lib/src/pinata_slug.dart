part of pinata;

class PinataSlug {
  //...Fields
  final String id;
  final String name;
  final String key;
  final String secret;
  final String userID;
  final List<KeyAccess> access;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool revoked;
  final int? maxUses;
  final int uses;

  PinataSlug._({
    required this.id,
    required this.name,
    required this.key,
    required this.secret,
    required this.userID,
    required this.access,
    required this.createdAt,
    required this.updatedAt,
    required this.revoked,
    required this.maxUses,
    required this.uses,
  });

  factory PinataSlug._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return PinataSlug._(
      id: data['id'],
      name: data['name'] ?? '',
      key: data['key'],
      secret: data['secret'],
      userID: data['user_id'],
      uses: data['uses'],
      revoked: data['revoked'] ?? false,
      maxUses: data['max_uses'],
      access: KeyAccess._fromJson(data['scopes']),
      createdAt: DateTime.tryParse(data['createdAt']),
      updatedAt: DateTime.tryParse(data['createdAt']),
    );
  }

  @override
  String toString() {
    return 'Pinata(\n'
        '\tid: $id,\n'
        '\tname: $name,\n'
        '\tkey: $key,\n'
        '\tsecret: $secret,\n'
        '\tuserID: $userID,\n'
        '\taccess: $access,\n'
        '\tcreatedAt: $createdAt,\n'
        '\tupdatedAt: $updatedAt,\n'
        '\trevoked: $revoked,\n'
        '\tmaxUses: $maxUses,\n'
        '\tuses: $uses,\n'
        ')';
  }

  Future<bool> revokeBy(Pinata admin) async {
    //...
    final payload = {"apiKey": key};
    final request = Request(
      'PUT',
      Uri.parse('${admin._uRL}/users/revokeApiKey'),
    );
    request.headers.addAll({
      'Content-Type': 'application/json',
      ...admin._access,
    });
    request.body = json.encode(payload);
    final overload = await request.send();
    final response = await Response.fromStream(overload);
    if (response.statusCode != 200) {
      throw Exception('error ${response.statusCode}'
          ' : ${response.reasonPhrase}');
    }
    return true;
  }
}
