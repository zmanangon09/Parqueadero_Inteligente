import 'package:flutter_test/flutter_test.dart';
import 'package:pry_final_parqueadero/domain/entities/espacio_entity.dart';
import 'package:pry_final_parqueadero/domain/usecases/espacios/actualizar_ocupacion_usecase.dart';

EspacioEntity espacio(int numero, EstadoEspacio estado) => EspacioEntity(
      id: 'e$numero',
      parqueaderoId: 'p1',
      numero: numero,
      estado: estado,
      tipo: TipoEspacio.normal,
    );

void main() {
  test('reparte vehículos detectados y respeta espacios reservados', () {
    final espacios = [
      espacio(1, EstadoEspacio.libre),
      espacio(2, EstadoEspacio.reservado),
      espacio(3, EstadoEspacio.ocupado),
      espacio(4, EstadoEspacio.libre),
    ];

    final propuesta =
        ActualizarOcupacionUseCase.sugerirOcupacion(espacios, 2);

    // Los 2 vehículos ocupan los primeros espacios no reservados.
    expect(propuesta[0].estado, EstadoEspacio.ocupado);
    expect(propuesta[1].estado, EstadoEspacio.reservado); // intacto
    expect(propuesta[2].estado, EstadoEspacio.ocupado);
    expect(propuesta[3].estado, EstadoEspacio.libre);
  });

  test('cero vehículos → todo libre salvo reservados', () {
    final espacios = [
      espacio(1, EstadoEspacio.ocupado),
      espacio(2, EstadoEspacio.reservado),
    ];

    final propuesta =
        ActualizarOcupacionUseCase.sugerirOcupacion(espacios, 0);

    expect(propuesta[0].estado, EstadoEspacio.libre);
    expect(propuesta[1].estado, EstadoEspacio.reservado);
  });

  test('más vehículos que espacios → todos los no reservados ocupados', () {
    final espacios = [
      espacio(1, EstadoEspacio.libre),
      espacio(2, EstadoEspacio.libre),
    ];

    final propuesta =
        ActualizarOcupacionUseCase.sugerirOcupacion(espacios, 5);

    expect(
        propuesta.every((e) => e.estado == EstadoEspacio.ocupado), isTrue);
  });
}
