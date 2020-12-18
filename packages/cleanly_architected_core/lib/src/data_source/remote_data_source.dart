import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:meta/meta.dart';

/// The data source which responsible to query data from the remote client.
abstract class RemoteQueryDataSource<T extends EquatableEntity,
    U extends QueryParams<T>> {
  /// Read [pageSize] amount of data from [client] based on [params] with
  /// page equals to [pageNumber]
  Future<List<T>> read({int pageSize, int pageNumber, U params});
}

/// The data source which responsible to handle form related request to the
/// server (create and update).
///
/// If you don't need a particular function, just throw a
/// [CleanException] when calling that function.
abstract class RemoteMutationDataSource<T extends EquatableEntity,
    U extends FormParams<T>> {
  /// Create data with [params] and return T as the result.
  Future<T> create({@required U params}) {
    throw UnimplementedError();
  }

  /// Update data to [params] and return T as the result.
  Future<T> update({@required U params}) {
    throw UnimplementedError();
  }

  /// Update data in server with [id]
  Future<void> delete({String id}) {
    throw UnimplementedError();
  }
}
