import 'package:cleanly_architected/src/clean_error.dart';
import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:cleanly_architected/src/repository/mutation_repository.dart';
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

class _TestEntityDeletionParams extends DeletionParams<_TestEntity> {
  final String name;

  _TestEntityDeletionParams(this.name);
  @override
  List<Object> get props => [name];
}

class MockLocalMutationDataSource extends Mock
    implements
        LocalMutationDataSource<_TestEntity, _TestEntityMutationParams> {}

class MockRemoteMutationDataSource extends Mock
    implements
        RemoteMutationDataSource<_TestEntity, _TestEntityMutationParams,
            _TestEntityDeletionParams> {}

void main() {
  final mutationParamsFixture = _TestEntityMutationParams('abc');
  final deletionParamsFixture = _TestEntityDeletionParams('abc');
  MockLocalMutationDataSource mockLocalDataSource;
  MockRemoteMutationDataSource mockRemoteDataSource;
  MutationRepository<_TestEntity, _TestEntityMutationParams,
      _TestEntityDeletionParams> repo;

  setUp(() {
    mockLocalDataSource = MockLocalMutationDataSource();
    mockRemoteDataSource = MockRemoteMutationDataSource();
    repo = MutationRepository(
      localMutationDataSource: mockLocalDataSource,
      remoteMutationDataSource: mockRemoteDataSource,
    );
  });

  test('should assign data sources correctly', () {
    expect(repo.localMutationDataSource, mockLocalDataSource);
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
  });

  group('delete', () {
    group('should handle exception', () {
      test('for UNEXPECTED_ERROR', () async {
        when(mockRemoteDataSource.delete(params: anyNamed('params')))
            .thenThrow(Exception());

        final result = await repo.delete(params: deletionParamsFixture);

        expect(
          (result as Left).value,
          const CleanFailure(name: 'UNEXPECTED_ERROR'),
        );
      });
      test('for CleanException', () async {
        when(mockRemoteDataSource.delete(params: anyNamed('params'))).thenThrow(
          const CleanException(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );

        final result = await repo.delete(params: deletionParamsFixture);

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
  });
}
