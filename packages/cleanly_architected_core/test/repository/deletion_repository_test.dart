import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/repository/deletion_repository.dart';
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

class _TestEntityDeletionParams extends DeletionParams<_TestEntity> {
  final String name;

  _TestEntityDeletionParams(this.name, [String entityId])
      : super(entityId: entityId);
  @override
  List<Object> get props => [name, entityId];
}

class MockRemoteDeletionDataSource extends Mock
    implements
        RemoteDeletionDataSource<_TestEntity, _TestEntityDeletionParams> {}

void main() {
  final deletionParamsFixture = _TestEntityDeletionParams('abc', '1');
  MockRemoteDeletionDataSource mockDataSource;
  DeletionRepository<_TestEntity, _TestEntityDeletionParams> repo;

  setUp(() {
    mockDataSource = MockRemoteDeletionDataSource();
    repo = DeletionRepository(remoteDataSource: mockDataSource);
  });

  group('delete', () {
    group('should handle exception', () {
      test('for UNEXPECTED_ERROR', () async {
        when(mockDataSource.delete(params: anyNamed('params')))
            .thenThrow(Exception());

        final result = await repo.delete(params: deletionParamsFixture);

        expect(
          (result as Left).value,
          const CleanFailure(name: 'UNEXPECTED_ERROR'),
        );
      });
      test('for CleanException', () async {
        when(mockDataSource.delete(params: anyNamed('params'))).thenThrow(
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

    test('should call data source delete', () async {
      await repo.delete(params: deletionParamsFixture);

      verify(mockDataSource.delete(
        params: deletionParamsFixture,
      ));
    });
  });
}
