part of pinata;

extension on Object? {
  //...Getters
  Object? get en {
    //...
    final value = this;
    // NUMBER
    if (value is num) {
      return value;
    }
    // STRING
    if (value is String) {
      return value;
    }
    // DATE TIME
    if (value is DateTime) {
      return value.toIso8601String();
    }
    // ITERABLE
    if (value is Iterable<Object?>) {
      return [for (var value in value) value.en];
    }
    if (value is Map<Object?, Object?>) {
      return Map.fromEntries([
        for (var value in value.entries) //
          MapEntry(value.key, value.value.en),
      ]);
    }
    return value;
  }

  Object? get de {
    //...
    final value = this;
    // NUMBER
    if (value is num) {
      return value;
    }
    // STRING
    if (value is String) {
      // DATE TIME
      final date = DateTime.tryParse(value);
      if (date != null) return date;
      return value;
    }
    // ITERABLE
    if (value is Iterable<Object?>) {
      return [for (var value in value) value.de];
    }
    if (value is Map<Object?, Object?>) {
      return Map.fromEntries([
        for (var value in value.entries) //
          MapEntry(value.key, value.value.de),
      ]);
    }
    return null;
  }
}

Map<String, Object?> _decode(data) {
  //...
  if (data is Map) {
    final map = data.de as Map<Object?, Object?>;
    return map.map((k, v) => MapEntry('$k', v));
  }
  return {};
}
