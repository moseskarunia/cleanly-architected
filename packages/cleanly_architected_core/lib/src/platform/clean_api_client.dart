import 'package:meta/meta.dart';

/// Implement this from your http client of choice to make it independent
/// from other layer in the application.
///
/// In this layer, you also need to convert http library's exceptions into
/// [CleanException]. This way, the repository layer can converts it into
/// [Failure] with ease.
abstract class CleanApiClient {
  /// Get the data under [path] with [queryParams]
  Future<List<Map<String, dynamic>>> read({
    @required String path,
    Map<String, dynamic> queryParams,
  });

  /// Update the data under [path] with [body]
  Future<Map<String, dynamic>> create({
    @required String path,
    Map<String, dynamic> body,
  });

  /// Update the data under [path] with [body]
  Future<Map<String, dynamic>> update({
    @required String path,
    Map<String, dynamic> body,
  });

  /// Calls the server to delete data under [path] which satisfies [params]
  Future<void> delete({@required String path, Map<String, dynamic> params});
}
