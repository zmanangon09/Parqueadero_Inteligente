import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/pago_entity.dart';
import '../../domain/repositories/pago_repository.dart';
import '../datasources/remote/pago_remote_datasource.dart';
import '../models/pago_model.dart';

class PagoRepositoryImpl implements PagoRepository {
  final PagoRemoteDatasource _datasource;
  PagoRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, PagoEntity>> registrarPago(PagoEntity pago) async {
    try {
      final saved = await _datasource.registrarPago(PagoModel.fromEntity(pago));
      return Right(saved);
    } catch (e) {
      return Left(ServerFailure('Error al procesar el pago: $e'));
    }
  }
}
