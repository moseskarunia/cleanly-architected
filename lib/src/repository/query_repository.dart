import 'package:cleanly_architected/src/clean_error.dart';
import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
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
///
/// For now, it just support infinite list style pagination, because the data it
/// returns is list.take([pageNumber]*[pageSize])
class QueryRepository<T extends EquatableEntity, U extends QueryParams<T>> {
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
  /// Take [pageNumber]x[pageNumber] amount of data from the [cachedData].
  /// If [cachedData]'s length is lesser and not
  /// yet [endOfList], will read from [localDataSource] (if provided).
  ///
  /// If the result from [localQueryDataSource] and [cachedData] satisfies the
  /// [pageNumber] and [pageSize], will immediately returns the data, otherwise,
  /// will call [remoteQueryDataSource] with [pageNumber] and [pageSize].
  ///
  /// If the remoteDataSource result length is at least equal to [pageSize],
  /// then, set the [endOfList] to false. (Otherwise, true) and then append
  /// the newest obtained data to [cachedData], and call localDataSource's
  /// [putAll].
  Future<Either<CleanFailure, List<T>>> readNext({
    @required int pageSize,
    @required int pageNumber,
    @required U queryParams,
  }) async {
    int calculatedPageNumber = pageNumber;
    if (queryParams != lastQueryParams) {
      calculatedPageNumber = 1;
    }

    if ((endOfList && calculatedPageNumber != 1) ||
        (localQueryDataSource == null && remoteQueryDataSource == null)) {
      endOfList = true;
      return Right(cachedData.take(pageNumber * pageSize).toList());
    }

    await _queryLocally(queryParams: queryParams, pageSize: pageSize);

    if (cachedData.length >= calculatedPageNumber * pageSize) {
      return Right(cachedData.take(calculatedPageNumber * pageSize).toList());
    }

    await _queryRemotely(
      pageNumber: calculatedPageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    return Right(cachedData.take(calculatedPageNumber * pageSize).toList());
  }

  /// Immediately call the remote server at page 1 with [pageSize].
  /// If the call succeed, replace [cachedData] with the result, delete the
  /// cached data in local storage, and putAll [cachedData] to the local
  /// storage.
  Future<Either<CleanFailure, List<T>>> refreshAll({
    @required int pageSize,
    @required U queryParams,
  }) async {
    if (remoteQueryDataSource == null && localQueryDataSource == null) {
      endOfList = true;
      lastQueryParams = queryParams;
      return Right(cachedData.take(pageSize).toList());
    }

    if (remoteQueryDataSource == null) {
      final results = await localQueryDataSource.read(params: queryParams);
      endOfList = true;
      lastQueryParams = queryParams;
      cachedData = results;
      return Right(cachedData.take(pageSize).toList());
    }
    throw UnimplementedError();
  }

  /// Attempt to query locally with given [queryParams]. The query result
  /// will always replace [cachedData] since [localQueryDataSource] doesn't
  /// have pagination built in (on purpose)
  Future<void> _queryLocally({U queryParams, int pageSize}) async {
    if (localQueryDataSource == null) {
      return;
    }
    final localResults = await localQueryDataSource.read(params: queryParams);
    cachedData = [...localResults];
    lastQueryParams = queryParams;
    endOfList = localResults.length < pageSize;
  }

  /// Attempt to query remotely with given params, if succeed, will merge the
  /// data with [cachedData], removes duplicates, and store locally.
  Future<void> _queryRemotely({
    @required int pageSize,
    @required int pageNumber,
    @required U queryParams,
  }) async {
    if (remoteQueryDataSource == null) {
      endOfList = true;
      return;
    }

    final remoteResults = await remoteQueryDataSource.read(
      pageNumber: pageNumber,
      pageSize: pageSize,
      queryParams: queryParams,
    );

    cachedData = [...cachedData, ...remoteResults];
    final ids = cachedData.map((e) => e.id).toSet();
    cachedData.retainWhere((x) => ids.remove(x.id));

    if (localQueryDataSource != null) {
      await localQueryDataSource.putAll(data: cachedData);
    }

    lastQueryParams = queryParams;
    endOfList = remoteResults.length < pageNumber;
  }
}
