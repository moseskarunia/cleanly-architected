import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:cleanly_architected/src/platform/clean_local_storage.dart';
import 'package:meta/meta.dart';

/// Data source to which usually handles form caching so the user can return
/// to edit later without losing progress.
abstract class LocalMutationDataSource<T extends EquatableEntity,
    U extends MutationParams<T>> {
  final CleanLocalStorage storage;

  const LocalMutationDataSource({this.storage});

  /// Returns list of T which satisfies [params]
  Future<List<T>> read({@required U params});

  /// Put all [data] to the [storage]. You need to convert it into a key value
  /// pair in the implementation, which matches [storage.putAll()].
  Future<void> putAll({@required U data});

  /// Removes all the data under [st
  /// orageName] if [key] is not provided,
  /// and removes only the specified data under [key] if specified.
  Future<void> delete({String key});
}

/// The data source which responsible to manage interaction between T and
/// the local storage. This is usually used to store data obtained from the
/// server.
abstract class LocalQueryDataSource<T extends EquatableEntity,
    U extends QueryParams<T>> {
  final String storageName;
  final CleanLocalStorage storage;

  const LocalQueryDataSource({this.storageName, this.storage});

  /// Returns list of T which satisfies [params]
  Future<List<T>> read({@required U params});

  /// Put all [data] to the [storage]. You need to convert it into a key value
  /// pair in the implementation, which matches [storage.putAll()]
  Future<void> putAll({@required List<T> data}) async {
    if (storageName == null || storageName.isEmpty || storage == null) {
      return;
    }

    final filteredData =
        data.where((e) => e.id != null && e.id.isNotEmpty).toList();

    final Map<String, Map<String, dynamic>> reducedData = filteredData
        .fold<Map<String, Map<String, dynamic>>>(
            {}, (prev, e) => {...prev, e.id: e.toJson()});

    await storage.putAll(storageName: storageName, data: reducedData);
  }

  /// Removes all the data under [storageName] if [key] is not provided,
  /// and removes only the specified data under [key] if specified.
  Future<void> delete({String key});
}
