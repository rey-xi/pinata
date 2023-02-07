part of pinata;

class PinataLog {
  //...Fields
  final int count;
  final int debunkSize;
  final int totalSize;

  const PinataLog({
    required this.count,
    required this.debunkSize,
    required this.totalSize,
  });

  factory PinataLog._fromJson(data) {
    //...
    assert(data is Map<String, dynamic>);
    return PinataLog(
      count: data['pin_count'],
      debunkSize: data['pin_size_total'],
      totalSize: data['pin_size_with_replications_total'],
    );
  }
}
