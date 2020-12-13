import 'package:bloc/bloc.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'form_cubit.g.dart';

class CreateFormCubit<T extends EquatableEntity, U extends FormParams<T>,
    V extends QueryParams<T>> extends Cubit<FormState<T>> {
  final Create<T, U, V> _create;

  CreateFormCubit({
    Create<T, U, V> create,
    FormState<T> initialState = const FormState(),
  })  : _create = create,
        super(initialState);

  Future<void> create({@required U params}) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _create(params: params);

    final newState = result.fold(
      (failure) => state.copyWith(failure: failure, isLoading: false),
      (data) => state.copyWithNull(failure: true).copyWith(
            data: data,
            isLoading: false,
          ),
    );

    emit(newState);
  }
}

class UpdateFormCubit<T extends EquatableEntity, U extends FormParams<T>,
    V extends QueryParams<T>> extends Cubit<FormState<T>> {
  final Update<T, U, V> _update;

  UpdateFormCubit({
    Update<T, U, V> update,
    FormState<T> initialState = const FormState(),
  })  : _update = update,
        super(initialState);

  Future<void> update({@required U params}) async {
    if (state.isLoading) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _update(params: params);

    final newState = result.fold(
      (failure) => state.copyWith(failure: failure, isLoading: false),
      (data) => state.copyWithNull(failure: true).copyWith(
            data: data,
            isLoading: false,
          ),
    );

    emit(newState);
  }
}

@CopyWith(generateCopyWithNull: true)
class FormState<T extends EquatableEntity> extends Equatable {
  final bool isLoading;
  final T data;
  final CleanFailure failure;

  bool get isSuccessful => !isLoading && data != null && failure == null;
  bool get isError => !isLoading && failure != null;

  const FormState({
    this.data,
    this.failure,
    this.isLoading = false,
  });

  @override
  List<Object> get props => [data, failure, isLoading];
}
