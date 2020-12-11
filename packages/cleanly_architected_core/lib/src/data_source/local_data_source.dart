import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/platform/clean_local_storage.dart';
import 'package:meta/meta.dart';

/// Data source to which usually handles form caching so the user can return
/// to edit later without losing progress.
abstract class LocalFormDataSource<T extends EquatableEntity,
    U extends FormParams<T>> {
  /// Name of the storage or collection of local db.
  final String storageName;

  /// Storage is put on super class for convenience. You can always implement
  /// your own with storage from implementation.
  final CleanLocalStorage storage;

  const LocalFormDataSource({this.storageName, this.storage});

  /// Returns list of T which satisfies [params]
  Future<List<T>> read({@required U params});

  /// Put all [data] to the [storage]. You need to convert it into a key value
  /// pair in the implementation, which matches [storage.putAll()].
  Future<void> putAll({@required U data}) async {
    if (storageName == null || storageName.isEmpty || storage == null) {
      return;
    }

    await storage.putAll(storageName: storageName, data: data.toJson());
  }

  /// Removes all the data under [st
  /// orageName] if [key] is not provided,
  /// and removes only the specified data under [key] if specified.
  Future<void> delete({String key});
}

/// Manages local database which stored in [storage].
abstract class LocalQueryDataSource<T extends EquatableEntity,
    U extends QueryParams<T>> {
  /// Collection / table name
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
