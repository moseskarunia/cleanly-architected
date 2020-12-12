import 'package:meta/meta.dart';

/// Interface of local storage (shared preferences, hive, etc) to make other
/// layers not too dependant on 3rd party library.
abstract class CleanLocalStorage {
  /// Returns queried data from local database.
  ///
  /// * [storageName] storage or collection or table name of your local db
  /// * [queryParams] query parameter.
  Future<List<Map<String, dynamic>>> read({
    @required String storageName,
    Map<String, dynamic> queryParams,
  });

  /// Put all [data] to the [storageName]. You need to convert it into a key value
  /// pair in the implementation.
  ///
  /// * [data] Key value pair of data. Sample structure:
  ///
  /// ```dart
  /// /// The object you want to store
  /// final originalFruits = [
  ///   Fruit(id: '1', name: 'Apple'),
  ///   Fruit(id: '2', name: 'Grape')
  /// ]
  ///
  /// /// Suggestion on how you call it
  /// await putAll(
  ///   storageName: 'fruits',
  ///   data: {
  ///     '1': {
  ///       'id': '1'
  ///       'name': 'Apple'
  ///     },
  ///     '2': {
  ///       'id': '2',
  ///       'name': 'Grape'
  ///     }
  ///   }
  /// );
  /// ```
  Future<void> putAll({
    @required String storageName,
    @required Map<String, dynamic> data,
  });

  /// Delete data from local [storageName]. If [key] is provided,
  /// just delete data with that key, otherwise, you should delete
  /// the entire collection or table or storage.
  ///
  /// (Just an implementation suggestion. At the end it's up to your own
  /// implementation)
  Future<void> delete({
    @required String storageName,
    String key,
  });
}
