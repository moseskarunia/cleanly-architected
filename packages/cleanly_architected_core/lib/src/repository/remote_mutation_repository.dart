import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// The repository of form related functions and manages call to the remote.
///
/// In a more specific case, you can always make a class, extends this,
/// and override its properties. Otherwise, you just need to register it
/// to your service locator (such as [GetIt](https://pub.dev/packages/get_it))
/// with different T.
class RemoteMutationRepository<T extends EquatableEntity,
    U extends FormParams<T>> {
  final RemoteMutationDataSource<T, U> remoteMutationDataSource;

  RemoteMutationRepository({
    @required this.remoteMutationDataSource,
  });

  /// Request data creation to both remoteDataSource
  Future<Either<CleanFailure, T>> create({@required U params}) async {
    try {
      final result = await remoteMutationDataSource.create(params: params);
      return Right(result);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Request data update to both remoteDataSource.
  Future<Either<CleanFailure, T>> update({@required U params}) async {
    try {
      final result = await remoteMutationDataSource.update(params: params);
      return Right(result);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Request deletion to the remote data source.
  /// Unit is just a dartz term for 'void'.
  Future<Either<CleanFailure, Unit>> delete({String id}) async {
    try {
      await remoteMutationDataSource.delete(id: id);

      /// unit is just dartz term for 'void'
      return Right(unit);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }


}
