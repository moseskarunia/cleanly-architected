import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/platform/clean_api_client.dart';
import 'package:meta/meta.dart';

/// The data source which responsible to query data from the remote client.
abstract class RemoteQueryDataSource<T extends EquatableEntity,
    U extends QueryParams<T>> {
  /// Api client which interfaced with [CleanApiClient]. Feel free to use your
  /// own abstract and put it in this class's implementation
  final CleanApiClient client;

  const RemoteQueryDataSource({this.client});

  /// Read [pageSize] amount of data from [client] based on [params] with
  /// page equals to [pageNumber]
  Future<List<T>> read({int pageSize, int pageNumber, U params});
}

/// The data source which responsible to handle form related request to the
/// server (create and update).
///
/// If you don't need a particular function, just throw a
/// [CleanException] when calling that function.
abstract class RemoteFormDataSource<T extends EquatableEntity,
    U extends FormParams<T>> {
  /// Api client which interfaced with [CleanApiClient]. Feel free to use your
  /// own abstract and put it in this class's implementation
  final CleanApiClient client;

  const RemoteFormDataSource({this.client});

  /// Create data with [params] and return T as the result.
  Future<T> create({@required U params});

  /// Update data to [params] and return T as the result.
  Future<T> update({@required U params});
}

/// The data source which responsible to delete data from the remote client.
abstract class RemoteDeletionDataSource<T extends EquatableEntity,
    U extends DeletionParams<T>> {
  // Api client which interfaced with [CleanApiClient]. Feel free to use your
  /// own abstract and put it in this class's implementation
  final CleanApiClient client;

  const RemoteDeletionDataSource({this.client});

  /// Delete a data with satisfies specified [params].
  Future<void> delete({@required U params});
}
