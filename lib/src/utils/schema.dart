part of pinata;

/// ## Pin Schema
/// A file system simulator that helps to group
/// bytes into byte sections just as folder is
/// to files.
///
/// ```dart
/// final schema = PinSchema(
///   '/books',
///   children: [
///      PinSchema('/books/data'),
///      PinSchema('/books/dex'),
///   ]
/// ```
class PinSchema {
  //...Fields
  final String path;
  final Iterable<PinSchema> children;
  final Uint8List? bytes;

  const PinSchema._(this.path, {this.children = const [], this.bytes});

  const PinSchema.bytes(this.path, [this.bytes]) : children = const [];

  const PinSchema.fold(this.path, this.children) : bytes = null;

  factory PinSchema._parse_(String dir, paths) {
    //...
    paths as Iterable<String>;
    final pathsX = paths.toList();
    final skeleton = <PinSchema>[];
    //...
    bool check(String src) {
      //...
      final seg1 = Uri.parse(src).pathSegments.length;
      final seg2 = Uri.parse(dir).pathSegments.length;
      return seg1 == seg2 + 1;
    }

    for (String path in paths.where(check)) {
      //...
      bool check(String src) => File(src).parent.path == path;
      skeleton.add(PinSchema._parse_(path, pathsX.where(check)));
      pathsX.removeWhere(check);
    }
    return PinSchema._(dir, children: skeleton);
  }

  factory PinSchema._parse(Iterable<String> paths) {
    //...
    keyOf(e) => Uri.parse(e).pathSegments.first;
    realm(e) => PinSchema._parse_(e.key, e.value);
    final grouped = paths.groupListsBy(keyOf);
    final skeleton = grouped.entries.map(realm);
    if (skeleton.length == 1) return skeleton.first;
    return PinSchema._('/', children: skeleton); //...
  }

  //...Getters
  bool get isDirectory => children.isNotEmpty;

  //...Methods
  Future<PinSchema> load(String url, Pinata api) async {
    //...
    if (isDirectory) {
      final skeleton = <PinSchema>[];
      for (PinSchema each in children) {
        skeleton.add(await each.load(url, api));
      }
      return PinSchema._(path, children: skeleton);
    } else {
      final offset = RegExp(r'^[/\\]?\w+[/\\]?');
      final xpath = path.replaceFirst(offset, '');
      final response = await get(
        Uri.parse('$url/$xpath}'),
        headers: api._login,
      );
      if (response.statusCode != 200) {
        throw PinataException._(
          statusCode: response.statusCode,
          reasonPhrase: response.reasonPhrase,
        );
      }
      return PinSchema._(path, bytes: response.bodyBytes);
    }
  }

  Future<Files> save(String address, Directory dir) async {
    //...
    if (!dir.existsSync()) dir.createSync();
    if (isDirectory) {
      final files = <FileSystemEntity>[];
      for (PinSchema each in children) {
        files.addAll(await each.save(address, dir));
      }
      return Files(files);
    } else {
      final file = File('${dir.path}/ipfs-$address/$path');
      if (!file.existsSync()) file.createSync(recursive: true);
      if (bytes?.isNotEmpty ?? false) {
        final buffer = bytes!.buffer;
        await file.writeAsBytes(
          buffer.asUint8List(
            bytes!.offsetInBytes,
            bytes!.lengthInBytes,
          ),
        );
      }
      return Files.single(file);
    }
  }

  @override
  String toString() {
    //...
    final indentation = [];
    final pathUri = Uri.parse(path).pathSegments;
    for (int i = 0; i < pathUri.length; i++) {
      indentation.add('\t');
    }
    return '${indentation.join()}$path'
        '${children.isNotEmpty ? '\n' : ''}'
        '${children.map((e) => '$e').join('\n')}';
  }
}

class Files extends Iterable<FileSystemEntity> {
  //...Fields
  final Iterable<FileSystemEntity> files;

  const Files(this.files);

  Files.single(FileSystemEntity file) : files = [file];

  @override
  Iterator<FileSystemEntity> get iterator {
    return files.iterator;
  }
}
