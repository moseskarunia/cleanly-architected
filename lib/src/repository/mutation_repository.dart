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
    V extends DeletionParams<T>> {
  final RemoteMutationDataSource<T, U, V> remoteMutationDataSource;
  final LocalMutationDataSource<T, U> localMutationDataSource;

  MutationRepository({
    this.remoteMutationDataSource,
    this.localMutationDataSource,
  });

  /// Request data creation to both remote and local (if data source is not
  /// null)
  Future<Either<CleanFailure, T>> create({@required U params}) async {
    try {
      await remoteMutationDataSource.create(params: params);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Request data update to both remote and local (if data source is not null)
  Future<Either<CleanFailure, T>> update({@required U params}) async {
    try {
      await remoteMutationDataSource.update(params: params);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Request deletion to the remote and local data source. If [localOnly] is
  /// true, will only delete from local repo, otherwise, both.
  Future<Either<CleanFailure, Unit>> delete(
      {V params, bool localOnly = true}) async {
    try {
      await remoteMutationDataSource.delete(params: params);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(const CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }
}
