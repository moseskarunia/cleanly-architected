import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestClass extends EquatableEntity {
  _TestClass(String id) : super(id);

  @override
  List<Object> get props => [id];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

void main() {
  group('NoQueryParams', () {
    test('props', () {
      final q = NoQueryParams<_TestClass>();
      expect(q.props, []);
      expect(q, isA<QueryParams<_TestClass>>());
    });
  });

  group('NoMutationParams', () {
    test('props', () {
      final q = NoMutationParams<_TestClass>();
      expect(q.props, []);
      expect(q.toJson(), null);
      expect(q, isA<MutationParams<_TestClass>>());
    });
  });

  group('NoDeletionParams', () {
    test('props', () {
      final q = NoDeletionParams<_TestClass>(entityId: '123');
      expect(q.props, ['123']);
      expect(q, isA<DeletionParams<_TestClass>>());
    });
  });
}
