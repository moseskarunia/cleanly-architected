import 'package:cleanly_architected_core/src/clean_error.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/repository/query_repository.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Base interactor to call ReadNext.
///
/// This doesn't perform any validation.
/// If you need to validate, feel free to extends this. Otherwise, just register
/// it with T.
class ReadNext<T extends EquatableEntity, U extends QueryParams<T>> {
  final QueryRepository<T, U> repo;

  const ReadNext({@required this.repo});

  Future<Either<CleanFailure, List<T>>> call({
    @required int pageNumber,
    @required int pageSize,
    @required U queryParams,
  }) async =>
      await repo.readNext(
          pageNumber: pageNumber, pageSize: pageSize, queryParams: queryParams);
}

/// Base interactor to call RefreshAll.
///
/// This doesn't perform any validation.
/// If you need to validate, feel free to extends this. Otherwise, just register
/// it with T.
class RefreshAll<T extends EquatableEntity, U extends QueryParams<T>> {
  final QueryRepository<T, U> repo;

  const RefreshAll({@required this.repo});

  Future<Either<CleanFailure, List<T>>> call({
    @required int pageSize,
    @required U queryParams,
  }) async =>
      await repo.refreshAll(pageSize: pageSize, queryParams: queryParams);
}
