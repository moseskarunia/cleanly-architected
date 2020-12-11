import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/repository/form_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// Base create interactor.
///
/// If you need to do some validation, just extend this.
class Create<T extends EquatableEntity, U extends FormParams<T>> {
  final FormRepository<T, U> repo;

  const Create({@required this.repo});
  Future<Either<CleanFailure, T>> call({@required U params}) async =>
      await repo.create(params: params);
}

/// Base update interactor.
///
/// If you need to do some validation, just extend this.
class Update<T extends EquatableEntity, U extends FormParams<T>> {
  final FormRepository<T, U> repo;

  const Update({@required this.repo});

  Future<Either<CleanFailure, T>> call({@required U params}) async =>
      await repo.update(params: params);
}