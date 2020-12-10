import 'package:cleanly_architected/src/clean_error.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:cleanly_architected/src/repository/mutation_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Base create interactor.
///
/// If you need to do some validation, just extend this.
class Create<T extends EquatableEntity, U extends MutationParams<T>,
    V extends DeletionParams<T>, W extends QueryParams<T>> {
  final MutationRepository<T, U, V, W> repo;

  const Create({@required this.repo});
  Future<Either<CleanFailure, T>> call({@required U params}) async =>
      await repo.create(params: params);
}

/// Base update interactor.
///
/// If you need to do some validation, just extend this.
class Update<T extends EquatableEntity, U extends MutationParams<T>,
    V extends DeletionParams<T>, W extends QueryParams<T>> {
  final MutationRepository<T, U, V, W> repo;

  const Update({@required this.repo});

  Future<Either<CleanFailure, T>> call({@required U params}) async =>
      await repo.update(params: params);
}

/// Base delete interactor.
///
/// If you need to do some validation, just extend this.
class Delete<T extends EquatableEntity, U extends MutationParams<T>,
    V extends DeletionParams<T>, W extends QueryParams<T>> {
  final MutationRepository<T, U, V, W> repo;

  const Delete({@required this.repo});

  Future<Either<CleanFailure, Unit>> call({@required V params}) async =>
      await repo.delete(params: params);
}
