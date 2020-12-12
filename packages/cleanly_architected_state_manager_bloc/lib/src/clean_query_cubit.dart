import 'package:bloc/bloc.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:copy_with_extension/copy_with_extension.dart';

part 'clean_query_cubit.g.dart';

class CleanQueryCubit<T extends EquatableEntity, U extends QueryParams<T>>
    extends Cubit<CleanQueryState<T>> {
  final ReadNext<T, U> _readNext;
  final RefreshAll<T, U> _refreshAll;

  CleanQueryCubit({
    @required ReadNext<T, U> readNext,
    @required RefreshAll<T, U> refreshAll,
    CleanQueryState<T> initialState = const CleanQueryState(),
  })  : _readNext = readNext,
        _refreshAll = refreshAll,
        super(initialState);

  Future<void> readNext({@required int pageSize, U params}) async {
    final newPageNumber = state.pageNumber + 1;
    final result = await _readNext(
      params: params,
      pageSize: pageSize,
      pageNumber: newPageNumber,
    );

    // final newState = result.fold((failure)=>)
  }

  Future<void> refreshAll({@required int pageSize, U params}) async {
    //
  }

  Future<void> refreshCurrentPage({@required int pageSize, U params}) async {
    //
  }
}

@CopyWith(generateCopyWithNull: true)
class CleanQueryState<T extends EquatableEntity> extends Equatable {
  /// True when the cubit is waiting for data. You should
  final bool isLoading;

  /// Error object
  final CleanFailure failure;

  /// Obtained data in a list to make it more versatile.
  final List<T> data;

  /// Current page number. Default is 0, so when you call [readNext] at the
  /// first time, it'll be 1.
  final int pageNumber;

  /// Will be true if the last query result has less data than pageSize and
  /// readNext won't be triggered again.
  final bool endOfList;

  /// True when [isLoading] is false, and yet [failure] is not null
  bool get isError => failure != null && !isLoading;

  const CleanQueryState({
    this.data = const [],
    this.endOfList = false,
    this.failure,
    this.isLoading = false,
    this.pageNumber = 0,
  });

  @override
  List<Object> get props => [data, endOfList, failure, isLoading, pageNumber];
}
