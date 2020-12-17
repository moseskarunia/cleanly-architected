import 'package:cleanly_architected_core/src/utils/graph_ql_params.dart';
import 'package:meta/meta.dart';

/// Implement this from your http client of choice to make it independent
/// from other layer in the application.
///
/// In this layer, you also need to convert client's exceptions into
/// [CleanException]. This way, the repository layer can converts it into
/// [Failure] with ease.
///
/// There's only [post] which contains [GraphQLParams] since basically a GraphQL
/// request is always a post.
abstract class CleanApiClient {
  /// Send query request to the server.
  Future<List<Map<String, dynamic>>> get({
    @required String path,
    Map<String, dynamic> queryParams,
  });

  /// Send post request to the server.
  ///
  /// * [path] Your request path.
  /// * [body] Your request body.
  /// * [gqlParams] GraphQL-related convenient parameter. If this is a HTTP
  ///   request, then simply ignore this.
  Future<Map<String, dynamic>> post({
    @required String path,
    Map<String, dynamic> body,
    GraphQLParams gqlParams,
  });

  /// Send put / update request to the server
  Future<Map<String, dynamic>> put({
    @required String path,
    Map<String, dynamic> body,
  });

  /// Send delete request to the server.
  Future<void> delete({
    @required String path,
    Map<String, dynamic> params,
  });
}
