part of pinata;

/// ## Pin Meta
/// Pin meta object identity. Performing query
/// operations on an instance of pin meta will
/// produce a [PinMetaQuery].
/// <br/><br/>
///
/// Available query operations
/// - [greaterThan]
/// - [lessThan]
/// - [equalTo]
/// - [notEqualTo]
/// - [between]
/// - [contain]
/// - [notContain]
/// - [match]
/// <br/><br/>
///
/// ```dart
/// final query = PinMeta.at('type').greaterThan(2);
/// ```
class PinMeta {
  //...Fields
  final String _target;

  PinMeta.at(this._target);

  //...Methods
  /// Query against where value of pin meta target
  /// is greater than [value].
  /// ```json
  /// {'op' : 'gt'}
  /// ```
  PinMetaQuery greaterThan(Object value) {
    //...
    return PinMetaQuery._(
      target: _target,
      value1: value,
      operation: 'gt',
    );
  }

  /// Query against where value of pin meta target
  /// is less than [value].
  /// ```json
  /// {'op' : 'lt'}
  /// ```
  PinMetaQuery lessThan(Object value) {
    //...
    return PinMetaQuery._(
      target: _target,
      value1: value,
      operation: 'lt',
    );
  }

  /// Query against where value of pin meta target
  /// is equal to [value].
  /// ```json
  /// {'op' : 'eq'}
  /// ```
  PinMetaQuery equalTo(Object value) {
    //...
    return PinMetaQuery._(
      target: _target,
      value1: value,
      operation: 'eq',
    );
  }

  /// Query against where value of pin meta target
  /// is not equal to [value].
  /// ```json
  /// {'op' : 'ne'}
  /// ```
  PinMetaQuery notEqualTo(Object value) {
    //...
    return PinMetaQuery._(
      target: _target,
      value1: value,
      operation: 'ne',
    );
  }

  /// Query against where value of pin meta target
  /// is between [value1] and [value2].
  /// ```json
  /// {'op' : 'between'}
  /// ```
  PinMetaQuery between(Object value1, Object value2) {
    //...
    return PinMetaQuery._(
      target: _target,
      value1: value1,
      value2: value2,
      operation: 'between',
    );
  }

  /// Query against where value of pin meta target
  /// contains [value]. Specify fixes with '%'.
  /// ```json
  /// {'op' : 'like'}
  /// ```
  PinMetaQuery contain(Object value) {
    //...
    return PinMetaQuery._(
      target: _target,
      value1: value,
      operation: 'like',
    );
  }

  /// Query against where value of pin meta target
  /// does not contain [value]. Specify fixes with
  /// '%'.
  /// ```json
  /// {'op' : 'notLike'}
  /// ```
  PinMetaQuery notContain(Object value) {
    //...
    return PinMetaQuery._(
      target: _target,
      value1: value,
      operation: 'notLike',
    );
  }

  /// Query against where value of pin meta matching
  /// with [regex] is non null. If [ignoreCase] is
  /// true, regex will match content with argument
  /// option 'i'.
  /// ```json
  /// {'op' : 'regexp'}
  /// ```
  PinMetaQuery match(
    RegExp regex, [
    bool ignoreCase = false,
  ]) {
    //...
    return PinMetaQuery._(
      target: _target,
      value1: regex.pattern,
      operation: ignoreCase ? 'iRegexp' : 'regexp',
    );
  }
}

/// ## Pin Meta Query
/// Can be used to query pins based on fields /
/// target. Create queries by running [PinMeta]
/// query operations.
/// <br/><br/>
///
/// ```dart
/// final query = PinMeta.at('type').greaterThan(2);
/// ```
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
