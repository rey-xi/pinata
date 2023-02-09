import 'package:pinata/pinata.dart';

main() async {
  final Pin pin;
  final Pin pin2;
  final PinataKey key;
  print(key = Pinata.test.self);
  print(PinataKey.parse('$key'));
  print(Pinata.parse('${Pinata.test}'));
  print(
    pin = await Pinata.test.getPin(
      r'bafkreiaevsgxufybtqftq7s5dylhd'
      r'qthlbb5vsbzpea47jqsypxdzbqrfy',
    ),
  );
  print(Pin.parse('$pin'));
  final link = await key.api.pinJson(
    {'user': 'reymanuel.xi@gmail.com'},
    name: 'Kojo',
  );
  print(await pin.contentJson);
  print(
    pin2 = await Pinata.test.getPin(
      r'QmNPFiUHEdf13DGnu7cSktEGG6YKq'
      r'BLfUGD9osJuc3AeFS',
    ),
  );
  print(await pin2.contentBody);
  print(await link.fetchJson(key.api));
}
