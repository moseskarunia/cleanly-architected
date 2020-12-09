import 'package:cleanly_architected/src/clean_error.dart';
import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// This will automatically manages local storage and in-app caching.
///
/// In a more specific case, you can always make a class, extends this,
/// and override its properties. Otherwise, you just need to register it
/// to your service locator (such as [GetIt](https://pub.dev/packages/get_it))
/// with different T.
///
/// This [QueryRepository] will also automatically handles simple
/// pagination based on pageSize and pageNumber.
class QueryRepository<T, U extends QueryParams<T>> {
  final RemoteQueryDataSource<T, U> remoteQueryDataSource;
  final LocalQueryDataSource<T, U> localQueryDataSource;

  /// In app cached data. This data will be returned when calling [readNext] if
  /// [lastQueryParams] is equal to the last one.
  @visibleForTesting
  List<T> cachedData = [];

  /// [cachedData] will be returned when calling [readNext] if
  /// [lastQueryParams] is equal to the last one.
  @visibleForTesting
  U lastQueryParams;

  /// End of list is true if on the last remote query result count is shorter
  /// than requested pageSize.
  ///
  /// This to prevent unnecessary server call unless force refreshed with
  /// [refreshAll]
  @visibleForTesting
  bool endOfList = false;

  QueryRepository({
    this.remoteQueryDataSource,
    this.localQueryDataSource,
  });

  /// If [lastQueryParams] is different than [queryParams], will always request
  /// data from the server.
  ///
  /// Take [pageNumber] amount of data from the [cachedData] starting at
  /// [pageNumber]. If [cachedData]'s length is lesser than [pageSize] and not
  /// yet [endOfList], will read from [localDataSource] (if provided).
  ///
  /// If the result from [localQueryDataSource] and [cachedData] satisfies the
  /// [pageNumber] and [pageSize], will immediately returns the data,
  /// and set [endOfList] to false. Otherwise, will call [remoteQueryDataSource]
  /// with [pageNumber] and [pageSize].
  ///
  /// If the server response length is at least equal to [pageSize], then,
  /// set the [endOfList] to false. (Otherwise, true) and then append
  /// the newest obtained data to [cachedData], and call local storage's
  /// [putAll].
  Future<Either<CleanFailure, List<T>>> readNext({
    @required int pageSize,
    @required int pageNumber,
    @required U queryParams,
  }) async {
    if (queryParams == lastQueryParams &&
        cachedData.length >= pageNumber * pageSize) {
      final results = cachedData.take(pageNumber * pageSize).toList();
      return Right(results);
    }

    throw UnimplementedError();
  }

  /// Immediately call the remote server at page 1 with [pageSize].
  /// If the call succeed, replace [cachedData] with the result, delete the
  /// cached data in local storage, and putAll [cachedData] to the local
  /// storage.
  Future<Either<CleanFailure, List<T>>> refreshAll({
    @required int pageSize,
    @required U queryParams,
  }) async {
    //
  }
}
