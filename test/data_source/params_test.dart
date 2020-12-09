import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestClass extends Equatable {
  @override
  List<Object> get props => [];
}

void main() {
  group('NoQueryParams', () {
    test('props', () {
      final q = NoQueryParams<_TestClass>(pageNumber: 2, pageSize: 20);
      expect(q.props, [2, 20]);
      expect(q, isA<QueryParams<_TestClass>>());
    });
  });

  group('NoMutationParams', () {
    test('props', () {
      final q = NoMutationParams<_TestClass>();
      expect(q.props, []);
      expect(q, isA<MutationParams<_TestClass>>());
    });
  });

  group('NoDeletionParams', () {
    test('props', () {
      final q = NoDeletionParams<_TestClass>();
      expect(q.props, []);
      expect(q, isA<DeletionParams<_TestClass>>());
    });
  });
}
