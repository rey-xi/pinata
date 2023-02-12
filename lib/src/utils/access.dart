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
enum KeyAccess {
  //...Enumerations
  /// Access to fetch key logs from Pinata cloud
  /// gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.log]
  ///
  log('&log', 'Log'),

  /// Access to fetch active pins from Pinata cloud
  /// gateway.
  ///
  /// Gives access to:
  /// - [_PinataAPI.pins]
  /// - [_PinataAPI.queryPins]
  ///
  pins('&pins', 'Fetch Pins'),

  /// Access to pins files, directories and files
  /// byte data to Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pinFile]
  /// - [_PinataAPI.pinDirectory]
  /// - [_PinataAPI.pinBytes]
  ///
  pinFile('&pinFile', 'Pin File'),

  /// Access to pins json, array and objet to Pinata
  /// cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pinJson]
  /// - [_PinataAPI.pinArray]
  ///
  pinJson('&pinJson', 'Pin Json'),

  /// Access to pin document from a given Pinata
  /// address to another address on Pinata cloud
  /// gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pinFromAddress]
  ///
  pinFromAddress('&pinByID', 'Pin From Address'),

  /// Access to unpin or delete pinned documents
  /// on Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [Pin.unpin]
  ///
  unpin('&unpin', 'Unpin'),

  /// Access to fetch pending pin jobs on Pinata
  /// cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pinJobs]
  ///
  pinJobs('&pinJobs', 'Pin Jobs'),

  /// Access to fetch pin policies along with pins
  /// on Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [_PinataAPI.pins]
  ///
  pinPolicy('&pinPolicy', 'Pin Policy'),

  /// Access to update pinned documents meta data
  /// on Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [Pin.updateMeta]
  ///
  updatePinMeta('&xPinMeta', 'Update Pin Meta'),

  /// Access to update pinned documents policy
  /// on Pinata cloud gateway. <br/><br/>
  ///
  /// Gives access to:
  /// - [Pin.updateMeta]
  ///
  updatePinPolicy('&xPinPolicy', 'Update Pin Policy'),

  /// Admin access to pin, unpin, update, query and
  /// manage documents on Pinata cloud gateway. Also
  /// gives access to create, revoke and query other
  /// api keys in it's host node. <br/><br/>
  ///
  /// Gives extra access to:
  /// - [_PinataAPI.createKey]
  /// - [_PinataAPI.apiKeys]
  /// - [_PinataAPI.queryApiKeys]
  /// - [PinataKey.revokeBy]
  ///
  admin('&admin', 'Admin', [data, pinning]),

  /// Shortcut Access to give access to all data
  /// access:
  /// - [KeyAccess.log]
  /// - [KeyAccess.pins]
  ///
  data('&data', 'Data', [log, pins]),

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
  pinning('&pinning', 'Pinning', [
    pinFile,
    pinJson,
    pinFromAddress,
    updatePinMeta,
    pinJobs,
    unpin,
    updatePinPolicy,
    pinPolicy,
  ]);

  //...Fields
  final String code;
  final String name;
  final List<KeyAccess> children;

  const KeyAccess(
    this.code,
    this.name, [
    this.children = const [],
  ]);

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

  /// Check if this key access contains [access].
  /// returns same value as:
  /// ```dart
  /// '$this'.contains('$access');
  /// ```
  bool contains(KeyAccess access) {
    return '$this'.contains(access.code);
  }

  @override
  String toString() => code + children.join();
}

extension on Iterable<KeyAccess> {
  //...
  Map<String, Object> toJson() {
    //...
    bool f(x) => join().contains(x);
    return f('${KeyAccess.admin}')
        ? {'admin': true}
        : {
            "endpoints": {
              "data": {
                "pinList": f('${KeyAccess.pins}'),
                "userPinnedDataTotal": f('${KeyAccess.log}'),
              },
              "pinning": {
                "hashMetadata": f('${KeyAccess.updatePinMeta}'),
                'hashPinPolicy': f('${KeyAccess.updatePinPolicy}'),
                "pinByHash": f('${KeyAccess.pinFromAddress}'),
                "pinFileToIPFS": f('${KeyAccess.pinFile}'),
                "pinJSONToIPFS": f('${KeyAccess.pinJson}'),
                "pinJobs": f('${KeyAccess.pinJobs}'),
                "unpin": f('${KeyAccess.unpin}'),
                'userPinPolicy': f('${KeyAccess.pinPolicy}'),
              }
            }
          };
  }
}
