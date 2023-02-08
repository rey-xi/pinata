import 'package:pinata/pinata.dart';

main() async {
  print(
    await Pinata.test.getPinAt(
      r'bafkreiaevsgxufybtqftq7s5dylhd'
      r'qthlbb5vsbzpea47jqsypxdzbqrfy',
    ),
  );
}
