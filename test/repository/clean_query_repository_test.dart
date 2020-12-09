import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:cleanly_architected/src/repository/query_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  final String name;

  const _TestEntity(String id, this.name) : super(id);

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
    test('should returns as-is if endOfList and identical query params',
        () async {
      repo.cachedData = [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
      ];
      repo.endOfList = true;
      repo.lastQueryParams = _TestEntityQueryParams('abc');

      final results = await repo.readNext(
        pageNumber: 3,
        pageSize: 3,
        queryParams: _TestEntityQueryParams('abc'),
      );

      expect((results as Right).value, [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
      ]);
      verifyZeroInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });
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
        pageNumber: 2,
        pageSize: 3,
        queryParams: _TestEntityQueryParams('abc'),
      );

      expect((results as Right).value, [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
        _TestEntity('5', 'Strawberry'),
        _TestEntity('6', 'Pineapple'),
      ]);
      expect(repo.lastQueryParams, _TestEntityQueryParams('abc'));
      verifyZeroInteractions(mockRemoteDataSource);
      verifyZeroInteractions(mockLocalDataSource);
    });

    group('if cachedData is not enough', () {
      test('should return result from localQueryDataSource', () async {
        repo.cachedData = [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Pineapple'),
        ];
        repo.lastQueryParams = _TestEntityQueryParams('abc');

        when(mockLocalDataSource.read(any)).thenAnswer(
          (_) async => [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
            _TestEntity('4', 'Orange'),
            _TestEntity('5', 'Strawberry'),
            _TestEntity('6', 'Pineapple'),
          ],
        );

        final results = await repo.readNext(
          pageNumber: 2,
          pageSize: 3,
          queryParams: _TestEntityQueryParams('abc'),
        );

        expect((results as Right).value, [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Pineapple'),
          _TestEntity('4', 'Orange'),
          _TestEntity('5', 'Strawberry'),
          _TestEntity('6', 'Pineapple'),
        ]);
        expect(repo.lastQueryParams, _TestEntityQueryParams('abc'));
        expect(repo.cachedData, [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Pineapple'),
          _TestEntity('4', 'Orange'),
          _TestEntity('5', 'Strawberry'),
          _TestEntity('6', 'Pineapple'),
        ]);
        verify(mockLocalDataSource.read(_TestEntityQueryParams('abc')));
        verifyZeroInteractions(mockRemoteDataSource);
      });
    });
  });

  group('if cachedData and localDataSource not enough', () {
    test('should return remoteDataSource results and remove duplicates',
        () async {
      repo.cachedData = [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
      ];
      repo.lastQueryParams = _TestEntityQueryParams('abc');

      when(mockLocalDataSource.read(any)).thenAnswer(
        (_) async => [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Pineapple'),
          _TestEntity('4', 'Orange'),
        ],
      );

      when(mockRemoteDataSource.read(
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
        queryParams: anyNamed('queryParams'),
      )).thenAnswer(
        (_) async => [
          _TestEntity('4', 'Orange'),
          _TestEntity('5', 'Strawberry'),
          _TestEntity('6', 'Pineapple'),
        ],
      );

      final results = await repo.readNext(
        pageNumber: 2,
        pageSize: 3,
        queryParams: _TestEntityQueryParams('abc'),
      );

      expect((results as Right).value, [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
        _TestEntity('5', 'Strawberry'),
        _TestEntity('6', 'Pineapple'),
      ]);
      expect(repo.lastQueryParams, _TestEntityQueryParams('abc'));
      expect(repo.cachedData, [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
        _TestEntity('5', 'Strawberry'),
        _TestEntity('6', 'Pineapple'),
      ]);
      expect(repo.endOfList, false);
      verifyInOrder([
        mockLocalDataSource.read(_TestEntityQueryParams('abc')),
        mockRemoteDataSource.read(
          pageNumber: 2,
          pageSize: 3,
          queryParams: _TestEntityQueryParams('abc'),
        ),
        mockLocalDataSource.delete(),
        mockLocalDataSource.putAll(
          data: [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
            _TestEntity('4', 'Orange'),
            _TestEntity('5', 'Strawberry'),
            _TestEntity('6', 'Pineapple'),
          ],
        )
      ]);
    });
  });
}
