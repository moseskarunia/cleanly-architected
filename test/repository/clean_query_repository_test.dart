import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected/src/repository/query_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends Equatable {
  final String id, name;

  const _TestEntity(this.id, this.name);
  @override
  List<Object> get props => [id, name];
}

class _TestEntityQueryParams extends QueryParams<_TestEntity> {
  final String name;

  _TestEntityQueryParams(this.name);
  @override
  List<Object> get props => [name];
}

class MockLocalDataSource extends Mock
    implements LocalQueryDataSource<_TestEntity, _TestEntityQueryParams> {}

class MockRemoteDataSource extends Mock
    implements RemoteQueryDataSource<_TestEntity, _TestEntityQueryParams> {}

void main() {
  MockLocalDataSource mockLocalDataSource;
  MockRemoteDataSource mockRemoteDataSource;
  QueryRepository<_TestEntity, _TestEntityQueryParams> repo;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    repo = QueryRepository(
      localQueryDataSource: mockLocalDataSource,
      remoteQueryDataSource: mockRemoteDataSource,
    );
  });

  test('initial properties', () {
    expect(repo.cachedData, []);
    expect(repo.lastQueryParams, null);
    expect(repo.endOfList, false);
  });

  group('readNext', () {
    test('should return cachedData if has sufficient length', () async {
      repo.cachedData = [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
        _TestEntity('5', 'Strawberry'),
        _TestEntity('6', 'Pineapple'),
      ];
      repo.lastQueryParams = _TestEntityQueryParams('abc');

      final results = await repo.readNext(
        pageNumber: 1,
        pageSize: 5,
        queryParams: _TestEntityQueryParams('abc'),
      );

      expect((results as Right).value, [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
        _TestEntity('5', 'Strawberry'),
      ]);
      expect(repo.lastQueryParams, _TestEntityQueryParams('abc'));
      verifyZeroInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });
  });
}
