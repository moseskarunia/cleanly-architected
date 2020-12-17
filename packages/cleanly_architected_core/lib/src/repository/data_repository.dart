import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/data_source/local_data_source.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';

/// This will automatically manages local storage and in-app caching.
///
/// In a more specific case, you can always make a class, extends this,
/// and override its properties. Otherwise, you just need to register it
/// to your service locator (such as [GetIt](https://pub.dev/packages/get_it))
/// with different T.
///
/// This [DataRepository] will also automatically handles simple
/// pagination based on pageSize and pageNumber.
///
/// For now, it just support infinite list style pagination, because the data it
/// returns is list.take([pageNumber]*[pageSize])
class DataRepository<T extends EquatableEntity, U extends QueryParams<T>> {
  final RemoteQueryDataSource<T, U> remoteQueryDataSource;
  final LocalDataSource<T, U> localDataSource;

  /// In app cached data. This data will be returned when calling [readNext] if
  /// [lastParams] is equal to the last one.
  @visibleForTesting
  List<T> cachedData = [];

  /// [cachedData] will be returned when calling [readNext] if
  /// [lastParams] is equal to the last one.
  @visibleForTesting
  U lastParams;

  /// End of list is true if on the last remote query result count is shorter
  /// than requested pageSize.
  ///
  /// This to prevent unnecessary server call unless force refreshed with
  /// [refreshAll]
  @visibleForTesting
  bool endOfList = false;

  DataRepository({
    this.remoteQueryDataSource,
    this.localDataSource,
  });

  /// If [lastParams] is different than [params], will always request
  /// data from the server.
  ///
  /// Take [pageNumber]x[pageNumber] amount of data from the [cachedData].
  /// If [cachedData]'s length is lesser and not
  /// yet [endOfList], will read from [localDataSource] (if provided).
  ///
  /// If the result from [localDataSource] and [cachedData] satisfies the
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
    @required U params,
  }) async {
    try {
      int calculatedPageNumber = pageNumber;
      if (params != lastParams) {
        calculatedPageNumber = 1;
      }

      if ((endOfList && calculatedPageNumber != 1) ||
          (localDataSource == null && remoteQueryDataSource == null)) {
        endOfList = true;
        return Right(cachedData.take(pageNumber * pageSize).toList());
      }

      await _queryLocally(params: params, pageSize: pageSize);

      if (cachedData.length >= calculatedPageNumber * pageSize) {
        return Right(cachedData.take(calculatedPageNumber * pageSize).toList());
      }

      await _queryRemotely(
        pageNumber: calculatedPageNumber,
        pageSize: pageSize,
        params: params,
      );

      return Right(cachedData.take(calculatedPageNumber * pageSize).toList());
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Immediately call the remote server at page 1 with [pageSize].
  /// If the call succeed, replace [cachedData] with the result, delete the
  /// cached data in local storage, and putAll [cachedData] to the local
  /// storage.
  Future<Either<CleanFailure, List<T>>> refreshAll({
    @required int pageSize,
    @required U params,
  }) async {
    try {
      if (remoteQueryDataSource == null && localDataSource == null) {
        endOfList = true;
        lastParams = params;
        return Right(cachedData.take(pageSize).toList());
      }

      if (remoteQueryDataSource == null) {
        await _queryLocally(pageSize: pageSize, params: params);
        endOfList = true;
        return Right(cachedData.take(pageSize).toList());
      }

      await _queryRemotely(
        pageNumber: 1,
        pageSize: pageSize,
        params: params,
      );

      return Right(cachedData.take(pageSize).toList());
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Removes data with key equals to [id] from localDataSource and
  /// remoteQueryDataSource.
  ///
  /// * [id] is optional, so that you can use this to clear the entire
  /// collection if null (implement this behavior in localDataSource's
  /// delete)
  Future<Either<CleanFailure, Unit>> deleteLocalData({String id}) async {
    try {
      if (localDataSource == null) {
        throw const CleanException(name: 'NO_LOCAL_DATA_SOURCE');
      }
      await localDataSource.delete(id: id);

      if (lastParams != null) {
        final localResults = await localDataSource.read(params: lastParams);
        cachedData = [...localResults];
      }

      return Right(unit);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Put one or more data with key equals to [e.entityIdentifier] and value to [e.toJson()]
  /// in the localDataSource, where e is each data in the array.
  Future<Either<CleanFailure, Unit>> putLocalData(
      {@required List<T> data}) async {
    try {
      if (localDataSource == null) {
        throw const CleanException(name: 'NO_LOCAL_DATA_SOURCE');
      }

      await localDataSource.putAll(data: data);

      if (lastParams != null) {
        final localResults = await localDataSource.read(params: lastParams);
        cachedData = [...localResults];
      }

      return Right(unit);
    } on CleanException catch (e) {
      return Left(CleanFailure(name: e.name, data: e.data, group: e.group));
    } catch (_) {
      return Left(CleanFailure(name: 'UNEXPECTED_ERROR'));
    }
  }

  /// Attempt to query locally with given [params]. The query result
  /// will always replace [cachedData] since [localDataSource] doesn't
  /// have pagination built in (on purpose)
  Future<void> _queryLocally({U params, int pageSize}) async {
    if (localDataSource == null) {
      return;
    }
    final localResults = await localDataSource.read(params: params);
    cachedData = [...localResults];
    lastParams = params;
    endOfList = localResults.length < pageSize;
  }

  /// Attempt to query remotely with given params, if succeed, will merge the
  /// data with [cachedData], removes duplicates, and store locally.
  Future<void> _queryRemotely({
    @required int pageSize,
    @required int pageNumber,
    @required U params,
  }) async {
    if (remoteQueryDataSource == null) {
      endOfList = true;
      return;
    }

    final remoteResults = await remoteQueryDataSource.read(
      pageNumber: pageNumber,
      pageSize: pageSize,
      params: params,
    );

    cachedData = [...cachedData, ...remoteResults];
    final ids = cachedData.map((e) => e.entityIdentifier).toSet();
    cachedData.retainWhere((x) => ids.remove(x.entityIdentifier));

    if (localDataSource != null) {
      await localDataSource.putAll(data: cachedData);
    }

    lastParams = params;
    endOfList = remoteResults.length < pageNumber;
  }
}
