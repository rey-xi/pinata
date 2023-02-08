part of pinata;

/// ## Pinata Key Access
/// Enum based constructed class that serves as
/// permission or access negotiation to Pinata
/// api keys.  Key Access describes what Pinata
/// cloud api features a pinata key has access to.
/// <br/><br/>
///
/// ```dart
/// final key = adminKey.createKey(
///   name: 'My new key',
///   access: [KeyAccess.admin],
/// )
/// ```
class KeyAccess {
  //...Fields
  final Iterable<String> _codes;
  final String _name;

  const KeyAccess._(this._codes, [this._name = 'Key ACCESS']);

  static List<KeyAccess> _fromJson(data) {
    //...
    if (data is! Map) return <KeyAccess>[];
    final endP = data['endpoints'] ?? {'': ''};
    return [
      if (data['admin'] ?? false) admin,
      if (endP['data']?['pinList'] ?? false) pins,
      if (endP['data']?['userPinnedDataTotal'] ?? false) log,
      if (endP['pinning']?['hashMetadata'] ?? false) updatePinMeta,
      if (endP['pinning']?['hashPinPolicy'] ?? false) updatePinPolicy,
      if (endP['pinning']?['pinByHash'] ?? false) pinFromAddress,
      if (endP['pinning']?['pinFileToIPFS'] ?? false) pinFile,
      if (endP['pinning']?['pinJSONToIPFS'] ?? false) pinJson,
      if (endP['pinning']?['pinJobs'] ?? false) pinJobs,
      if (endP['pinning']?['unpin'] ?? false) unpin,
      if (endP['pinning']?['userPinPolicy'] ?? false) pinPolicy,
    ];
  }

  /// Access to fetch key logs from Pinata cloud
  /// gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.log]
  ///
  static const log = KeyAccess._(['&log'], 'Log');

  /// Access to fetch active pins from Pinata cloud
  /// gateway.
  ///
  /// Gives access to:
  /// - [_PinataAPI.pins]
  /// - [_PinataAPI.queryPins]
  ///
  static const pins = KeyAccess._(['&pins'], 'Fetch Pins');

  /// Access to pins files, directories and files
  /// byte data to Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pinFile]
  /// - [_PinataAPI.pinDirectory]
  /// - [_PinataAPI.pinBytes]
  ///
  static const pinFile = KeyAccess._(['&pinFile'], 'Pin File');

  /// Access to pins json, array and objet to Pinata
  /// cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pinJson]
  /// - [_PinataAPI.pinArray]
  /// - [_PinataAPI.pinValue]
  ///
  static const pinJson = KeyAccess._(['&pinJson'], 'Pin Json');

  /// Access to pin document from a given Pinata
  /// address to another address on Pinata cloud
  /// gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pinFromAddress]
  ///
  static const pinFromAddress = KeyAccess._(['&pinByID'], 'Pin From Address');

  /// Access to unpin or delete pinned documents
  /// on Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [Pin.unpin]
  ///
  static const unpin = KeyAccess._(['&unpin'], 'Unpin');

  /// Access to fetch pending pin jobs on Pinata
  /// cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pinJobs]
  ///
  static const pinJobs = KeyAccess._(['&pinJobs'], 'Pin Jobs');

  /// Access to fetch pin policies along with pins
  /// on Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pins]
  ///
  static const pinPolicy = KeyAccess._(['&pinPolicy'], 'Pin Policy');

  /// Access to update pinned documents meta data
  /// on Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [Pin.update]
  ///
  static const updatePinMeta = KeyAccess._(['&xPinMeta'], 'Update Pin Meta');

  /// Access to update pinned documents policy
  /// on Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [Pin.update]
  ///
  static const updatePinPolicy = KeyAccess._(['&xPinPolicy'], 'Update Pin Policy');

  /// Admin access to pin, unpin, update, query and
  /// manage documents on Pinata cloud gateway. Also
  /// gives access to create, revoke and query other
  /// api keys in it's host node. <br/><br/>
  ///
  /// Gives extra access to:
  /// - [_PinataAPI.createKey]
  /// - [_PinataAPI.apiKeys]
  /// - [_PinataAPI.apiKeysAt]
  /// - [PinataKey.revokeBy]
  ///
  static final admin = KeyAccess._(['&admin'], 'Admin');

  /// Shortcut Access to give access to all data
  /// access:
  /// - [KeyAccess.log]
  /// - [KeyAccess.pins]
  ///
  static final data = KeyAccess._([
    '$log',
    '$pins',
  ], 'Data');

  /// Shortcut Access to give access to all data
  /// access:
  /// - [KeyAccess.pinFile]
  /// - [KeyAccess.pinJson]
  /// - [KeyAccess.pinFromAddress]
  /// - [KeyAccess.updatePinMeta]
  /// - [KeyAccess.pinJobs]
  /// - [KeyAccess.unpin]
  /// - [KeyAccess.updatePinPolicy]
  /// - [KeyAccess.pinPolicy]
  ///
  static final pinning = KeyAccess._([
    '$pinFile',
    '$pinJson',
    '$pinFromAddress',
    '$updatePinMeta',
    '$pinJobs',
    '$unpin',
    '$updatePinPolicy',
    '$pinPolicy',
  ], 'Pinning');

  //...Methods
  Map<String, Object> _toJson() {
    //...
    bool f(x) => '$this'.contains(x); //
    return f('$admin')
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
                "pinByHash": f('$pinFromAddress'),
                "pinFileToIPFS": f('$pinFile'),
                "pinJSONToIPFS": f('$pinJson'),
                "pinJobs": f('$pinJobs'),
                "unpin": f('$unpin'),
                'userPinPolicy': f('$pinPolicy')
              }
            }
          };
  }

  /// Check if this key access contains [access].
  /// returns same value as:
  /// ```dart
  /// '$this'.contains('$access');
  /// ```
  bool contains(KeyAccess access) => '$this'.contains('$access');

  @override
  String toString() => _codes.join();
}
