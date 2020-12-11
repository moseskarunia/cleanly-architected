import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/data_source/local_data_source.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/repository/mutation_repository.dart';
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

class _TestEntityQueryParams extends QueryParams<_TestEntity> {
  final String name;

  _TestEntityQueryParams(this.name);
  @override
  List<Object> get props => [name];
}

class _TestEntityMutationParams extends MutationParams<_TestEntity> {
  final String name;

  _TestEntityMutationParams(this.name);
  @override
  List<Object> get props => [name];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class MockLocalMutationDataSource extends Mock
    implements
        LocalMutationDataSource<_TestEntity, _TestEntityMutationParams> {}

class MockRemoteMutationDataSource extends Mock
    implements
        RemoteMutationDataSource<_TestEntity, _TestEntityMutationParams> {}

class MockLocalQueryDataSource extends Mock
    implements LocalQueryDataSource<_TestEntity, _TestEntityQueryParams> {}

void main() {
  final mutationParamsFixture = _TestEntityMutationParams('abc');
  MockRemoteMutationDataSource mockRemoteDataSource;
  MockLocalQueryDataSource mockLocalQueryDataSource;
  MutationRepository<_TestEntity, _TestEntityMutationParams,
      _TestEntityQueryParams> repo;

  setUp(() {
    mockLocalQueryDataSource = MockLocalQueryDataSource();
    mockRemoteDataSource = MockRemoteMutationDataSource();
    repo = MutationRepository(
      remoteMutationDataSource: mockRemoteDataSource,
      localQueryDataSource: mockLocalQueryDataSource,
    );
  });

  test('should assign data sources correctly', () {
    expect(repo.remoteMutationDataSource, mockRemoteDataSource);
    expect(repo.localQueryDataSource, mockLocalQueryDataSource);
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

    test('should return CleanFailure with NO_REMOTE_DATA_SOURCE', () async {
      repo = MutationRepository(remoteMutationDataSource: null);
      final result = await repo.create(params: mutationParamsFixture);
      expect(
        (result as Left).value,
        CleanFailure(name: 'NO_REMOTE_DATA_SOURCE'),
      );
    });
    group('should call create to remote mutation data source', () {
      Future<void> _performTest() async {
        when(mockRemoteDataSource.create(params: anyNamed('params')))
            .thenAnswer((_) async => _TestEntity('1', 'Apple'));
        final result = await repo.create(params: mutationParamsFixture);
        expect((result as Right).value, _TestEntity('1', 'Apple'));
      }

      test('and cache the result', () async {
        await _performTest();
        verifyInOrder([
          mockRemoteDataSource.create(params: mutationParamsFixture),
          mockLocalQueryDataSource.putAll(data: [_TestEntity('1', 'Apple')])
        ]);
      });

      test('and not cache the result', () async {
        repo = MutationRepository(
          remoteMutationDataSource: mockRemoteDataSource,
        );
        await _performTest();
        verify(mockRemoteDataSource.create(params: mutationParamsFixture));
        verifyZeroInteractions(mockLocalQueryDataSource);
      });
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

    test('should return CleanFailure with NO_REMOTE_DATA_SOURCE', () async {
      repo = MutationRepository(remoteMutationDataSource: null);
      final result = await repo.update(params: mutationParamsFixture);
      expect(
        (result as Left).value,
        CleanFailure(name: 'NO_REMOTE_DATA_SOURCE'),
      );
    });
    group('should call create to remote mutation data source', () {
      Future<void> _performTest() async {
        when(mockRemoteDataSource.update(params: anyNamed('params')))
            .thenAnswer((_) async => _TestEntity('1', 'Apple'));
        final result = await repo.update(params: mutationParamsFixture);
        expect((result as Right).value, _TestEntity('1', 'Apple'));
      }

      test('and cache the result', () async {
        await _performTest();
        verifyInOrder([
          mockRemoteDataSource.update(params: mutationParamsFixture),
          mockLocalQueryDataSource.putAll(data: [_TestEntity('1', 'Apple')])
        ]);
      });

      test('and not cache the result', () async {
        repo = MutationRepository(
          remoteMutationDataSource: mockRemoteDataSource,
        );
        await _performTest();
        verify(mockRemoteDataSource.update(params: mutationParamsFixture));
        verifyZeroInteractions(mockLocalQueryDataSource);
      });
    });
  });
}
