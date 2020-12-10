import 'package:cleanly_architected/src/clean_error.dart';
import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
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
    V extends DeletionParams<T>, W extends QueryParams<T>> {
  final RemoteMutationDataSource<T, U, V> remoteMutationDataSource;

  /// To cache the result after creating.
  final LocalQueryDataSource<T, W> localQueryDataSource;

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

  /// Request deletion to the remote and local data source. If [localOnly] is
  /// true, will only delete from local repo, otherwise, both.
  ///
  /// Unit is just a dartz term for 'void'.
  Future<Either<CleanFailure, Unit>> delete({@required V params}) async {
    try {
      if (remoteMutationDataSource == null && localQueryDataSource == null) {
        throw CleanException(name: 'NO_DATA_SOURCE_AVAILABLE');
      }

      if (remoteMutationDataSource != null) {
        await remoteMutationDataSource.delete(params: params);
      }

      if (localQueryDataSource != null &&
          params.entityId != null &&
          params.entityId.isNotEmpty) {
        await localQueryDataSource.delete(key: params.entityId);
      }

      /// unit is just dartz term for 'void'
      return Right(unit);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }
}
