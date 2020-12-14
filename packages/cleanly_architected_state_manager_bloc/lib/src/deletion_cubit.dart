import 'package:bloc/bloc.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// Manages state for deletion of an entity.
class DeletionCubit<T extends EquatableEntity, U extends FormParams<T>,
    V extends QueryParams<T>> extends Cubit<DeletionState<T>> {
  final Delete<T, U, V> _delete;

  DeletionCubit({
    Delete<T, U, V> delete,
    DeletionState<T> initialState = const DeletionState(),
  })  : _delete = delete,
        super(initialState);

  /// Delete T with provided [id]
  Future<void> delete({@required String id}) async {
    if (state.isLoading) {
      return;
    }

    emit(DeletionState<T>(
      isLoading: true,
      isSuccessful: false,
      failure: state.failure,
    ));

    final result = await _delete(id: id);

    final newState = result.fold(
      (failure) => DeletionState<T>(failure: failure),
      (_) => DeletionState<T>(isSuccessful: true),
    );

    emit(newState);
  }
}

/// Manages the state object of [DeletionCubit]
class DeletionState<T extends EquatableEntity> extends Equatable {
  final bool isLoading;

  /// True if the deletion succeed
  final bool isSuccessful;
  final CleanFailure failure;

  /// Whether this state contains an error or not
  bool get isError => !isLoading && failure != null;

  const DeletionState({
    this.failure,
    this.isSuccessful = false,
    this.isLoading = false,
  });

  @override
  List<Object> get props => [failure, isLoading, isSuccessful];
}
