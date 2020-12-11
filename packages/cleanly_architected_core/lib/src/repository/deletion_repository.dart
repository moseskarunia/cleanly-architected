import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

class DeletionRepository<T extends EquatableEntity,
    U extends DeletionParams<T>> {
  final RemoteDeletionDataSource<T, U> remoteDataSource;

  DeletionRepository({@required this.remoteDataSource});

  /// Request deletion to the remote and local data source. If [localOnly] is
  /// true, will only delete from local repo, otherwise, both.
  ///
  /// Unit is just a dartz term for 'void'.
  Future<Either<CleanFailure, Unit>> delete({@required U params}) async {
    try {
      await remoteDataSource.delete(params: params);
      /// unit is just dartz term for 'void'
      return Right(unit);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }
}
