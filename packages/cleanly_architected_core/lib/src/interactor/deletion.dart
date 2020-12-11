import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/repository/deletion_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Base delete interactor / use case.
///
/// If you need to do some validation, just extend this.
class Delete<T extends EquatableEntity, U extends DeletionParams<T>> {
  final DeletionRepository<T, U> repo;

  const Delete({@required this.repo});

  Future<Either<CleanFailure, Unit>> call({@required U params}) async =>
      await repo.delete(params: params);
}
