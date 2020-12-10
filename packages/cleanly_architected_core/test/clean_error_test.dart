import 'package:cleanly_architected_core/src/clean_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CleanException', () {
    test('props', () {
      final exception = CleanException(
        name: 'TEST_ERROR',
        group: 'PASSWORD',
        data: <String, dynamic>{'field1': 123},
      );
      expect(exception.props, [
        'TEST_ERROR',
        'PASSWORD',
        <String, dynamic>{'field1': 123},
      ]);
    });
  });

  group('CleanFailure', () {
    test('props', () {
      final failure = CleanFailure(
        name: 'TEST_ERROR',
        group: 'PASSWORD',
        data: <String, dynamic>{'field1': 123},
      );
      expect(failure.props, [
        'TEST_ERROR',
        'PASSWORD',
        <String, dynamic>{'field1': 123},
      ]);
    });

    test('code with group', () {
      final failure = CleanFailure(
        name: 'TEST_ERROR',
        group: 'PASSWORD',
        data: <String, dynamic>{'field1': 123},
      );
      expect(failure.code, 'error.PASSWORD.TEST_ERROR');
    });

    test('code without group (1)', () {
      final failure = CleanFailure(
        name: 'TEST_ERROR',
        data: <String, dynamic>{'field1': 123},
      );
      expect(failure.code, 'error.TEST_ERROR');
    });
    test('code without group (2)', () {
      final failure = CleanFailure(
        name: 'TEST_ERROR',
        group: '',
        data: <String, dynamic>{'field1': 123},
      );
      expect(failure.code, 'error.TEST_ERROR');
    });
  });
}
