import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:cleanly_architected/src/platform/clean_api_client.dart';
import 'package:meta/meta.dart';

/// The data source which responsible to query data from the remote client.
abstract class RemoteQueryDataSource<T extends EquatableEntity,
    U extends QueryParams<T>> {
  /// Api client which interfaced with [CleanApiClient]. Feel free to use your
  /// own abstract and put it in this class's implementation
  final CleanApiClient client;

  const RemoteQueryDataSource({this.client});

  /// Read [pageSize] amount of data from [client] based on [queryParams] with
  /// page equals to [pageNumber]
  Future<List<T>> read({int pageSize, int pageNumber, U queryParams});
}

/// The data source which responsible to mutate data from the remote client.
/// Mutation is a term to, well, mutate data. So it includes create, update,
/// and delete. If you don't need a particular function, just throw a
/// [CleanException] when calling that function.
abstract class RemoteMutationDataSource<T extends EquatableEntity,
    U extends MutationParams<T>, V extends DeletionParams<T>> {
  /// Api client which interfaced with [CleanApiClient]. Feel free to use your
  /// own abstract and put it in this class's implementation
  final CleanApiClient client;

  const RemoteMutationDataSource({this.client});

  /// Create data with [params] and return T as the result.
  Future<T> create({@required U params});

  /// Update data to [params] and return T as the result.
  Future<T> update({@required U params});

  /// Delete a data with satisfies specified [params].
  Future<void> delete({@required V params});
}
