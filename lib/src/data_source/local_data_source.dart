import 'package:cleanly_architected/src/data_source/clean_local_storage.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:meta/meta.dart';

/// The data source which responsible to manage interaction between T and
/// the local storage.
abstract class LocalDataSource<T, U extends QueryParams<T>> {
  final CleanLocalStorage storage;

  const LocalDataSource({@required this.storage});

  /// Returns list of T which satisfies [params]
  Future<List<T>> read(U params);

  /// Put all [data] to the [storage]. You need to convert it into a key value
  /// pair in the implementation, which matches [storage.putAll()]
  Future<void> putAll({
    @required String storageName,
    @required List<T> data,
  });

  /// Removes all the data under [storageName] if [key] is not provided,
  /// and removes only the specified data under [key] if specified.
  Future<void> delete({@required String storageName, String key});
}
