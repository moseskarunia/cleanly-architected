import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/repository/remote_mutation_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Base create interactor / use case.
///
/// If you need to do some validation, just extend this.
class Create<T extends EquatableEntity, U extends FormParams<T>> {
  final RemoteMutationRepository<T, U> repo;

  const Create({@required this.repo});

  Future<Either<CleanFailure, T>> call({@required U params}) async {
    final result = await repo.create(params: params);

    /// TODO: Cache to local query
    return result;
  }
}

/// Base update interactor / use case.
///
/// If you need to do some validation, just extend this.
class Update<T extends EquatableEntity, U extends FormParams<T>> {
  final RemoteMutationRepository<T, U> repo;

  const Update({@required this.repo});

  Future<Either<CleanFailure, T>> call({@required U params}) async {
    final result = await repo.update(params: params);

    /// TODO: Cache to local query
    return result;
  }
}

/// Base delete data interactor / use case.
///
/// If you need to do some validation, just extend this.
class Delete<T extends EquatableEntity, U extends FormParams<T>> {
  final RemoteMutationRepository<T, U> repo;

  const Delete({@required this.repo});

  Future<Either<CleanFailure, Unit>> call({String id}) async {
    final result = await repo.delete(id: id);

    /// TODO: Delete from local query
    return result;
  }
}
