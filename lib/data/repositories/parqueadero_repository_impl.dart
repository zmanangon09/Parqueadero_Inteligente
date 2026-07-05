import 'dart:math';

import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/espacio_entity.dart';
import '../../domain/entities/parqueadero_entity.dart';
import '../../domain/repositories/parqueadero_repository.dart';
import '../datasources/remote/parqueadero_remote_datasource.dart';
import '../models/espacio_model.dart';
import '../models/parqueadero_model.dart';

class ParqueaderoRepositoryImpl implements ParqueaderoRepository {
  final ParqueaderoRemoteDatasource _datasource;
  ParqueaderoRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<ParqueaderoEntity>>> getParqueaderosCercanos(
    double lat,
    double lng,
    double radiusKm,
  ) async {
    try {
      final all = await _datasource.getAll();
      final cercanos = all
          .where((p) => _haversineKm(lat, lng, p.lat, p.lng) <= radiusKm)
          .toList();
      return Right(cercanos);
    } catch (e) {
      return Left(ServerFailure('Error al cargar parqueaderos: $e'));
    }
  }

  @override
  Future<Either<Failure, ParqueaderoEntity>> getById(String id) async {
    try {
      final model = await _datasource.getById(id);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure('Error al cargar parqueadero: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveParqueadero(
    ParqueaderoEntity parqueadero,
    List<EspacioEntity> espacios,
  ) async {
    try {
      final pqModel = ParqueaderoModel(
        id: parqueadero.id,
        nombre: parqueadero.nombre,
        direccion: parqueadero.direccion,
        lat: parqueadero.lat,
        lng: parqueadero.lng,
        capacidadTotal: parqueadero.capacidadTotal,
        espaciosDisponibles: parqueadero.espaciosDisponibles,
        tarifaPorHora: parqueadero.tarifaPorHora,
        horario: parqueadero.horario,
        adminId: parqueadero.adminId,
      );
      final espModels = espacios
          .map((e) => EspacioModel(
                id: e.id,
                parqueaderoId: e.parqueaderoId,
                numero: e.numero,
                estado: e.estado,
                tipo: e.tipo,
              ))
          .toList();
      await _datasource.saveParqueadero(pqModel, espModels);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al guardar parqueadero: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getParqueaderosCount() async {
    try {
      final count = await _datasource.getParqueaderosCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure('Error al obtener total de parqueaderos: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> liberarEspacios(String parqueaderoId) async {
    try {
      await _datasource.liberarEspacios(parqueaderoId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error al liberar espacios: $e'));
    }
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371.0;
    final dLat = _rad(lat2 - lat1);
    final dLng = _rad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * r * asin(sqrt(a));
  }

  double _rad(double deg) => deg * pi / 180;
}
