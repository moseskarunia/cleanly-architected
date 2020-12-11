import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/data_source/local_data_source.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// The repository of mutation. This class manages form caching (coming soon), for example
/// in a case when you need to store state of a form to be edited again later.
///
/// In a more specific case, you can always make a class, extends this,
/// and override its properties. Otherwise, you just need to register it
/// to your service locator (such as [GetIt](https://pub.dev/packages/get_it))
/// with different T.
class MutationRepository<T extends EquatableEntity, U extends MutationParams<T>,
    V extends QueryParams<T>> {
  final RemoteMutationDataSource<T, U> remoteMutationDataSource;

  /// To cache the result after creating.
  final LocalQueryDataSource<T, V> localQueryDataSource;

  MutationRepository({
    this.remoteMutationDataSource,
    this.localQueryDataSource,
  });

  /// Request data creation to both remoteDataSource. If succeed, and result
  /// not null, cache in local.
  Future<Either<CleanFailure, T>> create({@required U params}) async {
    try {
      if (remoteMutationDataSource == null) {
        throw CleanException(name: 'NO_REMOTE_DATA_SOURCE');
      }
      final result = await remoteMutationDataSource.create(params: params);

      if (result != null) {
        await localQueryDataSource?.putAll(data: [result]);
      }

      return Right(result);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Request data update to both remoteDataSource. If succeed, and result
  /// not null, cache in local.
  Future<Either<CleanFailure, T>> update({@required U params}) async {
    try {
      if (remoteMutationDataSource == null) {
        throw CleanException(name: 'NO_REMOTE_DATA_SOURCE');
      }
      final result = await remoteMutationDataSource.update(params: params);

      if (result != null) {
        await localQueryDataSource?.putAll(data: [result]);
      }

      return Right(result);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }
}
