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
  final LocalMutationDataSource<T, U> localDataSource;

  MutationRepository({
    this.remoteMutationDataSource,
    this.localDataSource,
  });

  Future<Either<CleanFailure, T>> create({@required U params}) async {
    try {
      //
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  Future<Either<CleanFailure, T>> update({@required U params}) async {
    try {
      //
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }
}
