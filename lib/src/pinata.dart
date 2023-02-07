library pinata;

import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';

part 'pinata_imf.dart';
part 'pinata_log.dart';
part 'pinata_slug.dart';
part 'utils/access.dart';
part 'utils/hash.dart';
part 'utils/job.dart';
part 'utils/pin.dart';
part 'utils/query.dart';
part 'utils/slug.dart';

/// ## Pinata
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
class Pinata extends PinataImf {
  //...Fields
  Pinata.access({
    required super.access,
  }) : super._(name: 'One Time Access');

  /// Create Pinata from **[jWT]**. Optional **[apiKey]**
  /// and **[secret]** can be provided. ***[name]**
  ///
  Pinata.viaJWT({
    required super.name,
    required String jWT,
    String? apiKey,
    String? secret,
  }) : super._(
          access: {
            "Authorization": "Bearer $jWT",
          },
        );

  Pinata.viaPair({
    required super.name,
    required String apiKey,
    required String secret,
    String? jWT,
  }) : super._(
          access: {
            'pinata_api_key': apiKey,
            'pinata_secret_api_key': secret,
          },
        );

  Pinata.fromJson(data)
      : assert(data is Map),
        super._(
          name: data['name'] ?? '',
          access: data.containsKey('JWT')
              ? {'Authorization': "Bearer ${data['JWT']}"}
              : {_key: data[_key]!, _secret: data[_secret]!},
          //...
        );

  //...Utility
  /// ## Test Pinata IPFS from Rey
  static final test = Pinata.viaPair(
    name: 'Test Pinata IPFS from Rey',
    apiKey: r'ee94a0d47f29aee95b3a',
    secret: r'728667ffdd7cef7818cc1e1704b824c'
        r'a43c80eaf2af7c5bf534d3fffb39bd68a',
  );

  /// ## Test Admin Pinata IPFS from Rey
  static final testAdmin = Pinata.viaPair(
    name: 'Test Admin Pinata IPFS from Rey',
    apiKey: r'785953ce472639cd9a15',
    secret: r'3ed5778a27d7b712f73f7ec773426b'
        r'c8bf2c08a94263dd23006a03060adaf4d6',
  );
}

const _key = 'pinata_api_key';
const _secret = 'pinata_secret_api_key';
