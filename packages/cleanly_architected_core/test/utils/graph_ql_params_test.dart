import 'package:cleanly_architected_core/src/util/graph_ql_params.dart';
import 'package:test/test.dart';

void main() {
  group('gqlString', () {
    test('complete query', () {
      final params = GraphQLParams(
        type: GQLRequestType.query,
        functionName: 'getPeople',
        arguments: {'ageMin': 'Int!', 'ageMax': 'Int'},
        variables: {'ageMin': 25, 'ageMax': 30},
        fields: ['id', 'name', 'age'],
      );
      final String result = 'query GetPeople(\$ageMin:Int!,\$ageMax:Int) { ' +
          'action: getPeople(ageMin:\$ageMin,ageMax:\$ageMax) ' +
          '{ id,name,age } ' +
          '}';

      expect(params.gqlString, result);
    });
    test('without arguments', () {
      final params = GraphQLParams(
        type: GQLRequestType.query,
        functionName: 'getPeople',
        fields: ['id', 'name', 'age'],
      );
      final String result = 'query GetPeople() { ' +
          'action: getPeople() ' +
          '{ id,name,age } ' +
          '}';

      expect(params.gqlString, result);
    });

    test('mutation without fields', () {
      final params = GraphQLParams(
        type: GQLRequestType.mutation,
        functionName: 'updatePerson',
        arguments: {'id': 'String!', 'person': 'Person!'},
        variables: {
          'person': <String, dynamic>{'name': 'Jack', 'age': 20},
        },
      );
      final String result =
          'mutation UpdatePerson(\$id:String!,\$person:Person!) { ' +
              'action: updatePerson(id:\$id,person:\$person) ' +
              ' ' +
              '}';

      expect(params.gqlString, result);
    });
  });
}
