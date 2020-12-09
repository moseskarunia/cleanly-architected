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
    group('should call localDataSource', () {
      setUp(() {
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
      });
      test('with pageNumber 1, if queryParams is changed', () async {
        repo.endOfList = true;
        repo.lastQueryParams = _TestEntityQueryParams('def');
        final results = await repo.readNext(
          pageNumber: 2,
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

      test('with provided pageNumber, if queryParams unchanged', () async {
        repo.endOfList = false;
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
    });

    group('should call remoteDataSource', () {
      Future<void> _performTest({String queryParamString = 'abc'}) async {
        when(mockLocalDataSource.read(params: anyNamed('params'))).thenAnswer(
          (_) async => [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
          ],
        );

        repo.cachedData = [_TestEntity('1', 'Orange')];
        repo.endOfList = false;
        repo.lastQueryParams = _TestEntityQueryParams('def');

        return await repo.readNext(
          pageNumber: 2,
          pageSize: 3,
          queryParams: _TestEntityQueryParams(queryParamString),
        );
      }

      test('if localDataSource is null', () async {
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
        repo = QueryRepository(remoteQueryDataSource: mockRemoteDataSource);
        final results = await _performTest();

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
        verifyZeroInteractions(mockLocalDataSource);
        verify(mockRemoteDataSource.read(
          pageNumber: 1,
          pageSize: 3,
          queryParams: _TestEntityQueryParams('abc'),
        ));
      });
      group('if cachedData not enough', () {
        test('and with pageNumber 1, if queryParams changed', () async {
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
          final results = await _performTest();
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
        });
        test('and with provided pageNumber, if queryParams unchanged',
            () async {
          when(mockRemoteDataSource.read(
            pageNumber: anyNamed('pageNumber'),
            pageSize: anyNamed('pageSize'),
            queryParams: anyNamed('queryParams'),
          )).thenAnswer(
            (_) async => [
              _TestEntity('1', 'Orange'),
              _TestEntity('2', 'Strawberry'),
              _TestEntity('3', 'Pineapple'),
              _TestEntity('4', 'Apple'),
              _TestEntity('5', 'Banana'),
            ],
          );
          final results = await _performTest(queryParamString: 'def');

          expect((results as Right).value, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
            _TestEntity('4', 'Apple'),
            _TestEntity('5', 'Banana'),
          ]);
          expect(repo.cachedData, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
            _TestEntity('4', 'Apple'),
            _TestEntity('5', 'Banana'),
          ]);
          expect(repo.lastQueryParams, _TestEntityQueryParams('def'));
          expect(repo.endOfList, false);
          verifyInOrder([
            mockLocalDataSource.read(params: _TestEntityQueryParams('def')),
            mockRemoteDataSource.read(
              pageNumber: 2,
              pageSize: 3,
              queryParams: _TestEntityQueryParams('def'),
            ),
            mockLocalDataSource.putAll(
              data: [
                _TestEntity('1', 'Orange'),
                _TestEntity('2', 'Strawberry'),
                _TestEntity('3', 'Pineapple'),
                _TestEntity('4', 'Apple'),
                _TestEntity('5', 'Banana'),
              ],
            )
          ]);
        });
        test('(but return cachedData anyway if remote is null)', () async {
          repo = QueryRepository(localQueryDataSource: mockLocalDataSource);
          final results = await _performTest(queryParamString: 'def');

          expect((results as Right).value, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
          ]);
          expect(repo.cachedData, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
          ]);
          expect(repo.lastQueryParams, _TestEntityQueryParams('def'));
          expect(repo.endOfList, true);
          verify(mockLocalDataSource.read(
            params: _TestEntityQueryParams('def'),
          ));
          verifyZeroInteractions(mockRemoteDataSource);
        });
      });
    });

    group('when queryParams unchanged, should return cachedData directly', () {
      test('if endOfList true', () async {
        repo.cachedData = [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Apple'),
          _TestEntity('4', 'Banana'),
        ];
        repo.lastQueryParams = _TestEntityQueryParams('abc');
        repo.endOfList = true;
        final results = await repo.readNext(
          pageNumber: 2,
          pageSize: 3,
          queryParams: _TestEntityQueryParams('abc'),
        );

        expect((results as Right).value, [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Apple'),
          _TestEntity('4', 'Banana'),
        ]);
        expect(repo.endOfList, true);
        verifyZeroInteractions(mockLocalDataSource);
        verifyZeroInteractions(mockRemoteDataSource);
      });
      test('if both data source null', () async {
        repo = QueryRepository();
        repo.cachedData = [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Apple'),
          _TestEntity('4', 'Banana'),
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
          _TestEntity('3', 'Apple'),
          _TestEntity('4', 'Banana'),
        ]);
        expect(repo.endOfList, true);
        verifyZeroInteractions(mockLocalDataSource);
        verifyZeroInteractions(mockRemoteDataSource);
      });
    });
  });

  group('refreshAll', () {
    test('will not do anything if remoteDataSource null', () async {
      // TODO:
    });
    test('will immediately call remoteDataSource at page 1', () async {
      // TODO:
    });
  });
}
