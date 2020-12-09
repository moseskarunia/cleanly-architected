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

/// Note: Why I use `_TestEntityQueryParams('abc')`? Because the data source is
/// mocked. It doesn't matter the value of the queryparams.
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
    group('when queryParams is different', () {
      test('should call localDataSource if not null', () async {
        when(mockLocalDataSource.read(params: anyNamed('params'))).thenAnswer(
          (_) async => [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
            _TestEntity('4', 'Orange'),
            _TestEntity('5', 'Strawberry'),
            _TestEntity('6', 'Pineapple'),
          ],
        );
        repo.cachedData = [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Pineapple'),
          _TestEntity('4', 'Orange'),
        ];
        repo.endOfList = true;
        repo.lastQueryParams = _TestEntityQueryParams('def');
        final results = await repo.readNext(
          pageNumber: 3,
          pageSize: 3,
          queryParams: _TestEntityQueryParams('abc'),
        );

        expect((results as Right).value, [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Pineapple'),
        ]);
        expect(repo.cachedData, [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Pineapple'),
          _TestEntity('4', 'Orange'),
          _TestEntity('5', 'Strawberry'),
          _TestEntity('6', 'Pineapple'),
        ]);
        expect(repo.lastQueryParams, _TestEntityQueryParams('abc'));
        verify(mockLocalDataSource.read(params: _TestEntityQueryParams('abc')));
        verifyZeroInteractions(mockRemoteDataSource);
      });

      group('should call remoteDataSource', () {
        Future<void> _performTest() async {
          when(mockLocalDataSource.read(params: anyNamed('params'))).thenAnswer(
            (_) async => [
              _TestEntity('1', 'Orange'),
              _TestEntity('2', 'Strawberry'),
            ],
          );
          when(mockRemoteDataSource.read(
            pageNumber: anyNamed('pageNumber'),
            pageSize: anyNamed('pageSize'),
            queryParams: anyNamed('queryParams'),
          )).thenAnswer(
            (_) async => [
              _TestEntity('1', 'Orange'),
              _TestEntity('2', 'Strawberry'),
              _TestEntity('3', 'Pineapple'),
            ],
          );

          repo.cachedData = [_TestEntity('1', 'Orange')];
          repo.endOfList = false;
          repo.lastQueryParams = _TestEntityQueryParams('def');
          final results = await repo.readNext(
            pageNumber: 3,
            pageSize: 3,
            queryParams: _TestEntityQueryParams('abc'),
          );

          expect((results as Right).value, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
          ]);
          expect(repo.cachedData, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
          ]);
          expect(repo.lastQueryParams, _TestEntityQueryParams('abc'));
          expect(repo.endOfList, false);
        }

        test('if localDataSource result length < pageSize', () async {
          await _performTest();
          verifyInOrder([
            mockLocalDataSource.read(params: _TestEntityQueryParams('abc')),
            mockRemoteDataSource.read(
              pageNumber: 1,
              pageSize: 3,
              queryParams: _TestEntityQueryParams('abc'),
            ),
            mockLocalDataSource.putAll(
              data: [
                _TestEntity('1', 'Orange'),
                _TestEntity('2', 'Strawberry'),
                _TestEntity('3', 'Pineapple'),
              ],
            )
          ]);
        });
        test('if localDataSource is null', () async {
          repo = QueryRepository(
            remoteQueryDataSource: mockRemoteDataSource,
            localQueryDataSource: null,
          );
          await _performTest();
          verifyZeroInteractions(mockLocalDataSource);
          verify(mockRemoteDataSource.read(
            pageNumber: 1,
            pageSize: 3,
            queryParams: _TestEntityQueryParams('abc'),
          ));
        });
      });
    });

    // group('when cachedData.length is not enough', () {
    //   test('should call localDataSource', () {});
    //   test('should call remote directly if localDataSource null', () {});

    // test('should return ')
    // });
  });
}
