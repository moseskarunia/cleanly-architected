import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/repository/form_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  final String name;

  const _TestEntity(String id, this.name) : super(id);

  @override
  List<Object> get props => [id, name];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class _TestEntityFormParams extends FormParams<_TestEntity> {
  final String name;

  _TestEntityFormParams(this.name);
  @override
  List<Object> get props => [name];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class MockRemoteMutationDataSource extends Mock
    implements RemoteMutationDataSource<_TestEntity, _TestEntityFormParams> {}

void main() {
  final mutationParamsFixture = _TestEntityFormParams('abc');
  MockRemoteMutationDataSource mockRemoteDataSource;
  FormRepository<_TestEntity, _TestEntityFormParams> repo;

  setUp(() {
    mockRemoteDataSource = MockRemoteMutationDataSource();
    repo = FormRepository(
      remoteMutationDataSource: mockRemoteDataSource,
    );
  });

  test('should assign data sources correctly', () {
    expect(repo.remoteMutationDataSource, mockRemoteDataSource);
  });

  group('create', () {
    group('should handle exception', () {
      test('for UNEXPECTED_ERROR', () async {
        when(mockRemoteDataSource.create(params: anyNamed('params')))
            .thenThrow(Exception());

        final result = await repo.create(params: mutationParamsFixture);

        expect(
          (result as Left).value,
          const CleanFailure(name: 'UNEXPECTED_ERROR'),
        );
      });
      test('for CleanException', () async {
        when(mockRemoteDataSource.create(params: anyNamed('params'))).thenThrow(
          const CleanException(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );

        final result = await repo.create(params: mutationParamsFixture);

        expect(
          (result as Left).value,
          const CleanFailure(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );
      });
    });

    test('should call create to remote mutation data source', () async {
      when(mockRemoteDataSource.create(params: anyNamed('params')))
          .thenAnswer((_) async => _TestEntity('1', 'Apple'));
      final result = await repo.create(params: mutationParamsFixture);
      expect((result as Right).value, _TestEntity('1', 'Apple'));

      repo = FormRepository(
        remoteMutationDataSource: mockRemoteDataSource,
      );

      verify(mockRemoteDataSource.create(params: mutationParamsFixture));
    });
  });

  group('update', () {
    group('should handle exception', () {
      test('for UNEXPECTED_ERROR', () async {
        when(mockRemoteDataSource.update(params: anyNamed('params')))
            .thenThrow(Exception());

        final result = await repo.update(params: mutationParamsFixture);

        expect(
          (result as Left).value,
          const CleanFailure(name: 'UNEXPECTED_ERROR'),
        );
      });
      test('for CleanException', () async {
        when(mockRemoteDataSource.update(params: anyNamed('params'))).thenThrow(
          const CleanException(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );

        final result = await repo.update(params: mutationParamsFixture);

        expect(
          (result as Left).value,
          const CleanFailure(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );
      });
    });

    test('should call create to remote mutation data source', () async {
      when(mockRemoteDataSource.update(params: anyNamed('params')))
          .thenAnswer((_) async => _TestEntity('1', 'Apple'));
      final result = await repo.update(params: mutationParamsFixture);
      expect((result as Right).value, _TestEntity('1', 'Apple'));

      repo = FormRepository(
        remoteMutationDataSource: mockRemoteDataSource,
      );

      verify(mockRemoteDataSource.update(params: mutationParamsFixture));
    });
  });

  group('delete', () {
    group('should handle exception', () {
      test('for UNEXPECTED_ERROR', () async {
        when(mockRemoteDataSource.delete(id: anyNamed('id')))
            .thenThrow(Exception());

        final result = await repo.delete(id: '1');

        expect(
          (result as Left).value,
          const CleanFailure(name: 'UNEXPECTED_ERROR'),
        );
      });
      test('for CleanException', () async {
        when(mockRemoteDataSource.delete(id: anyNamed('id'))).thenThrow(
          const CleanException(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );

        final result = await repo.delete(id: '1');

        expect(
          (result as Left).value,
          const CleanFailure(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );
      });
    });

    test('should call data source delete', () async {
      await repo.delete(id: '1');

      verify(mockRemoteDataSource.delete(id: '1'));
    });
  });
}
