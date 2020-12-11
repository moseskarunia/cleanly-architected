import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Manages form cache so the user can continue editing later.
class FormCacheRepository<T extends EquatableEntity, U extends FormParams<T>> {
  final LocalFormCacheDataSource<T, U> localFormCacheDataSource;

  const FormCacheRepository({@required this.localFormCacheDataSource});

  /// Removes form cache of T from LocalMutationDataSource
  Future<Either<CleanFailure, Unit>> clearFormCache() async {
    //
  }

  /// Add [params] to LocalMutationDataSource.
  Future<Either<CleanFailure, Unit>> cacheForm({@required U params}) async {
    //
  }

  /// Replace value in LocalMutationDataSource with [params]
  Future<Either<CleanFailure, Unit>> updateFormCache({
    @required U params,
  }) async {
    //
  }

  ///  Retrieve form cache of T from LocalMutationDataSource if any.
  Future<Either<CleanFailure, U>> readFormCache() async {
    //
  }
}
