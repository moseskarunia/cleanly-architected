import 'package:meta/meta.dart';

enum GQLRequestType { query, mutation }

/// Parameters usually used in a GraphQL requests.
class GraphQLParams {
  /// Function arguments with its type. Both key and value should always string.
  /// ```
  /// {
  ///   "name": "String!"
  ///   "age": "Int"
  /// }
  /// ```
  final Map<String, String> arguments;

  /// Variables to be matched with [arguments]. Remember to register each keys
  /// in variables to [arguments].
  /// ```
  /// {
  ///   "name": "John Doe"
  ///   "age": 26
  /// }
  /// ```
  final Map<String, dynamic> variables;

  /// Fields you want to get from the server as response for your request.
  /// ```
  /// [ "name", "age" ]
  /// ```
  final List<String> fields;

  /// Function name you want to request to.
  final String functionName;

  /// The type of this gql request.
  final GQLRequestType type;

  /// Build a gqlSring for request.
  ///
  /// ```
  /// final params = GraphQLParams(
  ///   type: GQLRequestType.query,
  ///   functionName: 'getPeople',
  ///   arguments: {
  ///     'ageMin': 'Int!'
  ///     'ageMax': 'Int'
  ///   },
  ///   variables: {
  ///     'ageMin': 25,
  ///     'ageMax': 30
  ///   },
  ///   fields: [
  ///     id,
  ///     name,
  ///     age,
  ///   ],
  /// );
  ///
  /// ```
  ///
  /// ...and, the output of params.gqlString should equivalent to:
  /// ```
  /// query GetPeople($ageMin: Int!, $ageMax: Int) {
  ///   action: getPeople(ageMin: $ageMin, ageMax: $ageMax) {
  ///     id,
  ///     name,
  ///     age,
  ///   }
  /// }
  /// ```
  String get gqlString {
    final _type = type.toString().split('.')[1];
    final _pascalCaseFunctionName =
        functionName[0].toUpperCase() + functionName.substring(1);

    final _args =
        arguments?.entries?.map((e) => '\$${e.key}:${e.value}')?.join(',') ??
            '';
    final _actionArgs =
        arguments?.entries?.map((e) => '${e.key}:\$${e.key}')?.join(',') ?? '';
    String _fields = (fields?.join(',') ?? '').trim();

    if (_fields.isNotEmpty) {
      _fields = '{ $_fields }';
    }

    return '$_type $_pascalCaseFunctionName($_args) { ' +
        'action: $functionName($_actionArgs) ' +
        '$_fields ' +
        '}';
  }

  const GraphQLParams({
    @required this.type,
    @required this.functionName,
    this.arguments,
    this.variables,
    this.fields,
  });
}
