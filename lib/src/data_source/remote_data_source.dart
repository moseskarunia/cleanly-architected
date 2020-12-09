import 'package:cleanly_architected/src/clean_api_client.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:meta/meta.dart';

/// The data source which responsible to query data from the remote client.
abstract class RemoteQueryDataSource<T, U extends QueryParams<T>> {
  final CleanApiClient client;

  const RemoteQueryDataSource({@required this.client});

  Future<List<T>> read(U params);
}

/// The data source which responsible to mutate data from the remote client.
/// Mutation is a term to, well, mutate data. So it includes create, update,
/// and delete. If you don't need a particular function, just throw a
/// [CleanException] when calling that function
abstract class RemoteMutationDataSource<T, U extends MutationParams<T>,
    V extends DeletionParams<T>> {
  final CleanApiClient client;

  const RemoteMutationDataSource({@required this.client});

  /// Create data with [params] and return T as the result.
  Future<T> create(U params);

  /// Update data to [params] and return T as the result.
  Future<T> update(U params);

  /// Delete a data with satisfies specified [params].
  Future<void> delete(V params);
}
