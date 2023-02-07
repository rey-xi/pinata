part of pinata;

class KeyAccess {
  //...Fields
  final Iterable<String> _x;

  const KeyAccess._(this._x);

  static List<KeyAccess> _fromJson(data) {
    //...
    if (data is! Map) return <KeyAccess>[];
    final endP = data['endpoints'] ?? {'': ''};
    return [
      if (data['admin'] ?? false) adminAccess,
      if (endP['data']?['pinList'] ?? false) pins,
      if (endP['data']?['userPinnedDataTotal'] ?? false) log,
      if (endP['pinning']?['hashMetadata'] ?? false) updatePinMeta,
      if (endP['pinning']?['hashPinPolicy'] ?? false) updatePinPolicy,
      if (endP['pinning']?['pinByHash'] ?? false) pinByID,
      if (endP['pinning']?['pinFileToIPFS'] ?? false) pinFile,
      if (endP['pinning']?['pinJSONToIPFS'] ?? false) pinJson,
      if (endP['pinning']?['pinJobs'] ?? false) pinJobs,
      if (endP['pinning']?['unpin'] ?? false) unpin,
      if (endP['pinning']?['userPinPolicy'] ?? false) pinPolicy,
    ];
  }

  static const log = KeyAccess._(['&log']);

  static const pins = KeyAccess._(['&pins']);

  static const pinFile = KeyAccess._(['&pinFile']);

  static const pinJson = KeyAccess._(['&pinJson']);

  static const pinByID = KeyAccess._(['&pinByID']);

  static const unpin = KeyAccess._(['&unpin']);

  static const pinJobs = KeyAccess._(['&pinJobs']);

  static const pinPolicy = KeyAccess._(['&pinPolicy']);

  static const updatePinMeta = KeyAccess._(['&xPinMeta']);

  static const updatePinPolicy = KeyAccess._(['&xPinPolicy']);

  static final adminAccess = KeyAccess._([
    '&admin',
    '$dataAccess',
    '$pinningAccess',
  ]);

  static final dataAccess = KeyAccess._([
    '$log',
    '$pins',
  ]);

  static final pinningAccess = KeyAccess._([
    '$pinFile',
    '$pinJson',
    '$pinByID',
    '$updatePinMeta',
    '$pinJobs',
    '$unpin',
    '$updatePinPolicy',
    '$pinPolicy',
  ]);

  //...Methods
  Map<String, Object> toJson() {
    //...
    bool f(x) => '$this'.contains(x); //
    return f('$adminAccess')
        ? {'admin': true}
        : {
            "endpoints": {
              "data": {
                "pinList": f('$pins'),
                "userPinnedDataTotal": f('$log'),
              },
              "pinning": {
                "hashMetadata": f('$updatePinMeta'),
                'hashPinPolicy': f('$updatePinPolicy'),
                "pinByHash": f('$pinByID'),
                "pinFileToIPFS": f('$pinFile'),
                "pinJSONToIPFS": f('$pinJson'),
                "pinJobs": f('$pinJobs'),
                "unpin": f('$unpin'),
                'userPinPolicy': f('$pinPolicy')
              }
            }
          };
  }

  @override
  String toString() => _x.join();
}
