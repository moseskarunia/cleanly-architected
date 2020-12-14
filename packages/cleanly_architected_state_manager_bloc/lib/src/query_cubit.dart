import 'package:bloc/bloc.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// State manager to help query data.
class QueryCubit<T extends EquatableEntity, U extends QueryParams<T>>
    extends Cubit<QueryState<T>> {
  final ReadNext<T, U> _readNext;
  final RefreshAll<T, U> _refreshAll;

  QueryCubit({
    @required ReadNext<T, U> readNext,
    @required RefreshAll<T, U> refreshAll,
    QueryState<T> initialState = const QueryState(),
  })  : _readNext = readNext,
        _refreshAll = refreshAll,
        super(initialState);

  /// Read pageNumber+1 from the last state pageNumber. Doesn't emit anything
  /// if isLoading true.
  ///
  /// * [pageSize] Page size requested.
  /// * [params] Parameters
  /// * [toPage] When null, the value will be last state's pageNumber +1, if
  ///   not, will use this value
  Future<void> readNext({@required int pageSize, U params, int toPage}) async {
    if (state.isLoading) {
      return;
    }

    emit(QueryState<T>(
      isLoading: true,
      data: state.data,
      failure: state.failure,
      endOfList: state.endOfList,
      pageNumber: state.pageNumber,
    ));

    final newPageNumber = toPage ?? state.pageNumber + 1;

    final result = await _readNext(
      params: params,
      pageSize: pageSize,
      pageNumber: newPageNumber,
    );

    final newState = result.fold(
      (failure) => QueryState<T>(
        data: state.data,
        failure: failure,
        endOfList: state.endOfList,
        pageNumber: state.pageNumber,
      ),
      (data) => QueryState<T>(
        data: data,
        endOfList: newPageNumber * pageSize > data.length,
        pageNumber: state.pageNumber,
      ),
    );

    emit(newState);
  }

  /// Call from page 1 and tells repository layer to immediately try to get
  /// from remoteDataSource.
  Future<void> refreshAll({@required int pageSize, U params}) async {
    if (state.isLoading) {
      return;
    }

    emit(QueryState<T>(
      isLoading: true,
      data: state.data,
      failure: state.failure,
      endOfList: state.endOfList,
      pageNumber: state.pageNumber,
    ));

    final result = await _refreshAll(
      params: params,
      pageSize: pageSize,
    );

    final newState = result.fold(
      (failure) => QueryState<T>(
        data: state.data,
        failure: failure,
        endOfList: state.endOfList,
        pageNumber: state.pageNumber,
      ),
      (data) => QueryState<T>(
        data: data,
        pageNumber: 1,
        endOfList: pageSize > data.length,
      ),
    );

    emit(newState);
  }
}

/// State of [QueryCubit]
class QueryState<T extends EquatableEntity> extends Equatable {
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

  const QueryState({
    this.data = const [],
    this.endOfList = false,
    this.failure,
    this.isLoading = false,
    this.pageNumber = 0,
  });

  @override
  List<Object> get props => [data, endOfList, failure, isLoading, pageNumber];
}
