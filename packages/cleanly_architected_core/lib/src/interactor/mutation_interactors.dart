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
class Create<T extends EquatableEntity, U extends FormParams<T>,
    V extends QueryParams<T>> {
  final RemoteMutationRepository<T, U> mutationRepo;
  final DataRepository<T, V> dataRepo;

  const Create({@required this.mutationRepo, this.dataRepo});

  Future<Either<CleanFailure, T>> call({@required U params}) async {
    final result = await mutationRepo.create(params: params);

    if (result?.isRight() == true && dataRepo != null) {
      await dataRepo.putLocalData(data: [(result as Right).value]);
    }

    return result;
  }
}

/// Base update interactor / use case.
///
/// If you need to do some validation, just extend this.
class Update<T extends EquatableEntity, U extends FormParams<T>,
    V extends QueryParams<T>> {
  final RemoteMutationRepository<T, U> mutationRepo;
  final DataRepository<T, V> dataRepo;

  const Update({@required this.mutationRepo, this.dataRepo});

  Future<Either<CleanFailure, T>> call({@required U params}) async {
    final result = await mutationRepo.update(params: params);

    if (result?.isRight() == true && dataRepo != null) {
      await dataRepo.putLocalData(data: [(result as Right).value]);
    }

    return result;
  }
}

/// Base delete data interactor / use case.
///
/// If you need to do some validation, just extend this.
class Delete<T extends EquatableEntity, U extends FormParams<T>,
    V extends QueryParams<T>> {
  final RemoteMutationRepository<T, U> mutationRepo;
  final DataRepository<T, V> dataRepo;

  const Delete({@required this.mutationRepo, this.dataRepo});

  Future<Either<CleanFailure, Unit>> call({String id}) async {
    final result = await mutationRepo.delete(id: id);

    if (result?.isRight() == true && dataRepo != null) {
      await dataRepo.deleteLocalData(id: id);
    }

    return result;
  }
}
