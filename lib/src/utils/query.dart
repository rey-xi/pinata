part of pinata;

class PinMeta {
  //...Fields
  final String _trg;

  PinMeta.at(this._trg);

  //...Methods
  PinMetaQuery greaterThan(Object value) {
    //...
    return PinMetaQuery._(
      target: _trg,
      value1: value,
      operation: 'gt',
    );
  }

  PinMetaQuery lessThan(Object value) {
    //...
    return PinMetaQuery._(
      target: _trg,
      value1: value,
      operation: 'lt',
    );
  }

  PinMetaQuery equals(Object value) {
    //...
    return PinMetaQuery._(
      target: _trg,
      value1: value,
      operation: 'eq',
    );
  }

  PinMetaQuery notEqualTo(Object value) {
    //...
    return PinMetaQuery._(
      target: _trg,
      value1: value,
      operation: 'ne',
    );
  }

  PinMetaQuery between(Object value1, Object value2) {
    //...
    return PinMetaQuery._(
      target: _trg,
      value1: value1,
      value2: value2,
      operation: 'between',
    );
  }

  PinMetaQuery contain(Object value) {
    //...
    return PinMetaQuery._(
      target: _trg,
      value1: value,
      operation: 'like',
    );
  }

  PinMetaQuery notContain(Object value) {
    //...
    return PinMetaQuery._(
      target: _trg,
      value1: value,
      operation: 'notLike',
    );
  }

  PinMetaQuery match(Pattern value) {
    //...
    return PinMetaQuery._(
      target: _trg,
      value1: value,
      operation: 'regexp',
    );
  }
}

class PinMetaQuery {
  //...Fields
  final String target;
  final Object value1;
  final Object? value2;
  final String operation;

  PinMetaQuery._({
    required this.target,
    required this.operation,
    required this.value1,
    this.value2,
  });

  //...Methods
  @override
  String toString() {
    var tag = target;
    var val1 = value1;
    var val2 = value2;
    if (val1 is DateTime) {
      val1 = val1.toIso8601String();
    }
    if (val2 is DateTime) {
      val2 = val2.toIso8601String();
    }
    if (val1 is Pattern) {
      val1 = val1.toString();
    }
    if (val2 is Pattern) {
      val2 = val2.toString();
    }
    val1 = '"value":"$val1"';
    val2 = val2 != null ? ',"secondValue":"$val2"' : '';
    return '&metadata[keyvalues][$tag]={$val1$val2,"op"'
        ':"$operation"}';
  }
}
