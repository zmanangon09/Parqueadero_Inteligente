import 'package:flutter_test/flutter_test.dart';
import 'package:pry_final_parqueadero/core/utils/validators.dart';

void main() {
  group('numeroTarjeta', () {
    test('acepta 16 dígitos (con o sin espacios)', () {
      expect(Validators.numeroTarjeta('4242424242424242'), isNull);
      expect(Validators.numeroTarjeta('4242 4242 4242 4242'), isNull);
    });
    test('rechaza vacío', () {
      expect(Validators.numeroTarjeta(''), isNotNull);
    });
    test('rechaza longitud incorrecta', () {
      expect(Validators.numeroTarjeta('4242'), isNotNull);
    });
  });

  group('expiracionTarjeta', () {
    test('acepta MM/YY futura', () {
      expect(Validators.expiracionTarjeta('12/30'), isNull);
    });
    test('rechaza formato inválido', () {
      expect(Validators.expiracionTarjeta('1230'), isNotNull);
      expect(Validators.expiracionTarjeta('13/30'), isNotNull);
    });
    test('rechaza tarjeta vencida', () {
      expect(Validators.expiracionTarjeta('01/20'), isNotNull);
    });
  });

  group('cvc', () {
    test('acepta 3 dígitos', () => expect(Validators.cvc('123'), isNull));
    test('rechaza no-3-dígitos', () {
      expect(Validators.cvc('12'), isNotNull);
      expect(Validators.cvc('abcd'), isNotNull);
    });
  });
}
