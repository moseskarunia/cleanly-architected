import 'package:bloc/bloc.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'deletion_cubit.g.dart';

class DeletionCubit<T extends EquatableEntity, U extends FormParams<T>,
    V extends QueryParams<T>> extends Cubit<DeletionState<T>> {
  final Delete<T, U, V> _delete;

  DeletionCubit({
    Delete<T, U, V> delete,
    DeletionState<T> initialState = const DeletionState(),
  })  : _delete = delete,
        super(initialState);

  Future<void> delete({@required String id}) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true, isSuccessful: false));

    final result = await _delete(id: id);

    final newState = result.fold(
      (failure) => state.copyWith(
        failure: failure,
        isLoading: false,
        isSuccessful: false,
      ),
      (_) => state.copyWithNull(failure: true).copyWith(
            isSuccessful: true,
            isLoading: false,
          ),
    );

    emit(newState);
  }
}

@CopyWith(generateCopyWithNull: true)
class DeletionState<T extends EquatableEntity> extends Equatable {
  final bool isLoading, isSuccessful;
  final CleanFailure failure;

  bool get isError => !isLoading && failure != null;

  const DeletionState({
    this.failure,
    this.isSuccessful = false,
    this.isLoading = false,
  });

  @override
  List<Object> get props => [failure, isLoading, isSuccessful];
}
