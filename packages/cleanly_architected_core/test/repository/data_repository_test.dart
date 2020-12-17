import 'package:cleanly_architected_core/src/entity/clean_error.dart';
import 'package:cleanly_architected_core/src/data_source/local_data_source.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/repository/data_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  final String name;
  final String id;

  const _TestEntity(this.id, this.name);

  @override
  List<Object> get props => [id, name];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  String get entityIdentifier => id;
}

class _TestEntityQueryParams extends QueryParams<_TestEntity> {
  final String name;

  _TestEntityQueryParams(this.name);
  @override
  List<Object> get props => [name];
}

class MockLocalDataSource extends Mock
    implements LocalDataSource<_TestEntity, _TestEntityQueryParams> {}

class MockRemoteDataSource extends Mock
    implements RemoteQueryDataSource<_TestEntity, _TestEntityQueryParams> {}

/// Note: Why I use `_TestEntityQueryParams('abc')`? Because the data source is
/// mocked. It doesn't matter the value of the queryparams.
void main() {
  MockLocalDataSource mockLocalDataSource;
  MockRemoteDataSource mockRemoteDataSource;
  DataRepository<_TestEntity, _TestEntityQueryParams> repo;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    repo = DataRepository(
      localDataSource: mockLocalDataSource,
      remoteQueryDataSource: mockRemoteDataSource,
    );
  });

  test('initial properties', () {
    expect(repo.cachedData, []);
    expect(repo.lastParams, null);
    expect(repo.endOfList, false);
  });

  group('readNext', () {
    group('should handle exception', () {
      test('and return CleanFailure UNEXPECTED_ERROR', () async {
        when(mockLocalDataSource.read(params: anyNamed('params')))
            .thenThrow(Exception());

        final result = await repo.readNext(
          pageNumber: 1,
          pageSize: 2,
          params: _TestEntityQueryParams('def'),
        );

        expect((result as Left).value,
            const CleanFailure(name: 'UNEXPECTED_ERROR'));
      });
      test('and return CleanFailure with expected values', () async {
        when(mockLocalDataSource.read(params: anyNamed('params'))).thenThrow(
          const CleanException(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );

        final result = await repo.readNext(
          pageNumber: 1,
          pageSize: 2,
          params: _TestEntityQueryParams('def'),
        );

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
      test('with pageNumber 1, if params is changed', () async {
        repo.endOfList = true;
        repo.lastParams = _TestEntityQueryParams('def');
        final results = await repo.readNext(
          pageNumber: 2,
          pageSize: 3,
          params: _TestEntityQueryParams('abc'),
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
        expect(repo.lastParams, _TestEntityQueryParams('abc'));
        verify(mockLocalDataSource.read(params: _TestEntityQueryParams('abc')));
        verifyZeroInteractions(mockRemoteDataSource);
      });

      test('with provided pageNumber, if params unchanged', () async {
        repo.endOfList = false;
        repo.lastParams = _TestEntityQueryParams('abc');

        final results = await repo.readNext(
          pageNumber: 2,
          pageSize: 3,
          params: _TestEntityQueryParams('abc'),
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
        expect(repo.lastParams, _TestEntityQueryParams('abc'));
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
        repo.lastParams = _TestEntityQueryParams('def');

        return await repo.readNext(
          pageNumber: 2,
          pageSize: 3,
          params: _TestEntityQueryParams(queryParamString),
        );
      }

      test('if localDataSource is null', () async {
        when(mockRemoteDataSource.read(
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
          params: anyNamed('params'),
        )).thenAnswer(
          (_) async => [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
          ],
        );
        repo = DataRepository(remoteQueryDataSource: mockRemoteDataSource);
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
        expect(repo.lastParams, _TestEntityQueryParams('abc'));
        expect(repo.endOfList, false);
        verifyZeroInteractions(mockLocalDataSource);
        verify(mockRemoteDataSource.read(
          pageNumber: 1,
          pageSize: 3,
          params: _TestEntityQueryParams('abc'),
        ));
      });
      group('if cachedData not enough', () {
        test('and with pageNumber 1, if params changed', () async {
          when(mockRemoteDataSource.read(
            pageNumber: anyNamed('pageNumber'),
            pageSize: anyNamed('pageSize'),
            params: anyNamed('params'),
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
              params: _TestEntityQueryParams('abc'),
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
          expect(repo.lastParams, _TestEntityQueryParams('abc'));
          expect(repo.endOfList, false);
        });
        test('and with provided pageNumber, if params unchanged', () async {
          when(mockRemoteDataSource.read(
            pageNumber: anyNamed('pageNumber'),
            pageSize: anyNamed('pageSize'),
            params: anyNamed('params'),
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
          expect(repo.lastParams, _TestEntityQueryParams('def'));
          expect(repo.endOfList, false);
          verifyInOrder([
            mockLocalDataSource.read(params: _TestEntityQueryParams('def')),
            mockRemoteDataSource.read(
              pageNumber: 2,
              pageSize: 3,
              params: _TestEntityQueryParams('def'),
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
          repo = DataRepository(localDataSource: mockLocalDataSource);
          final results = await _performTest(queryParamString: 'def');

          expect((results as Right).value, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
          ]);
          expect(repo.cachedData, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
          ]);
          expect(repo.lastParams, _TestEntityQueryParams('def'));
          expect(repo.endOfList, true);
          verify(mockLocalDataSource.read(
            params: _TestEntityQueryParams('def'),
          ));
          verifyZeroInteractions(mockRemoteDataSource);
        });
      });
    });

    group('when params unchanged, should return cachedData directly', () {
      test('if endOfList true', () async {
        repo.cachedData = [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Apple'),
          _TestEntity('4', 'Banana'),
        ];
        repo.lastParams = _TestEntityQueryParams('abc');
        repo.endOfList = true;
        final results = await repo.readNext(
          pageNumber: 2,
          pageSize: 3,
          params: _TestEntityQueryParams('abc'),
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
        repo = DataRepository();
        repo.cachedData = [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Apple'),
          _TestEntity('4', 'Banana'),
        ];
        repo.lastParams = _TestEntityQueryParams('abc');
        final results = await repo.readNext(
          pageNumber: 2,
          pageSize: 3,
          params: _TestEntityQueryParams('abc'),
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
    group('should handle exception', () {
      test('and return CleanFailure UNEXPECTED_ERROR', () async {
        when(mockRemoteDataSource.read(
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
          params: anyNamed('params'),
        )).thenThrow(Exception());

        final result = await repo.refreshAll(
          pageSize: 2,
          params: _TestEntityQueryParams('def'),
        );

        expect((result as Left).value,
            const CleanFailure(name: 'UNEXPECTED_ERROR'));
      });
      test('and return CleanFailure with expected values', () async {
        when(mockRemoteDataSource.read(
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
          params: anyNamed('params'),
        )).thenThrow(
          const CleanException(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );

        final result = await repo.refreshAll(
          pageSize: 10,
          params: _TestEntityQueryParams('def'),
        );

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
    test(
      'will return cachedData and ignores params if no data source',
      () async {
        repo = DataRepository();
        repo.cachedData = [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Apple'),
        ];

        final results = await repo.refreshAll(
          pageSize: 2,
          params: _TestEntityQueryParams('abc'),
        );

        expect((results as Right).value, [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
        ]);
        expect(repo.endOfList, true);
        expect(repo.lastParams, _TestEntityQueryParams('abc'));
        verifyZeroInteractions(mockLocalDataSource);
        verifyZeroInteractions(mockRemoteDataSource);
      },
    );
    test('will call localDataSource only if remoteDataSource null', () async {
      repo = DataRepository(localDataSource: mockLocalDataSource);

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

      final results = await repo.refreshAll(
        pageSize: 5,
        params: _TestEntityQueryParams('abc'),
      );

      expect((results as Right).value, [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
        _TestEntity('5', 'Strawberry'),
      ]);
      expect(repo.cachedData, [
        _TestEntity('1', 'Orange'),
        _TestEntity('2', 'Strawberry'),
        _TestEntity('3', 'Pineapple'),
        _TestEntity('4', 'Orange'),
        _TestEntity('5', 'Strawberry'),
        _TestEntity('6', 'Pineapple'),
      ]);
      expect(repo.endOfList, true);
      expect(repo.lastParams, _TestEntityQueryParams('abc'));

      verify(mockLocalDataSource.read(params: _TestEntityQueryParams('abc')));
      verifyZeroInteractions(mockRemoteDataSource);
    });

    group('will call remoteDataSource', () {
      Future<void> _performTest() async {
        when(mockRemoteDataSource.read(
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
          params: anyNamed('params'),
        )).thenAnswer(
          (_) async => [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
          ],
        );

        final results = await repo.refreshAll(
          pageSize: 3,
          params: _TestEntityQueryParams('abc'),
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
        expect(repo.endOfList, false);
        expect(repo.lastParams, _TestEntityQueryParams('abc'));
      }

      test('', () async {
        await _performTest();
        verifyInOrder([
          mockRemoteDataSource.read(
            pageNumber: 1,
            pageSize: 3,
            params: _TestEntityQueryParams('abc'),
          ),
          mockLocalDataSource.putAll(data: [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
          ]),
        ]);
      });

      test('but without local caching if localDataSource null', () async {
        repo = DataRepository(remoteQueryDataSource: mockRemoteDataSource);
        await _performTest();
        verify(mockRemoteDataSource.read(
          pageNumber: 1,
          pageSize: 3,
          params: _TestEntityQueryParams('abc'),
        ));
        verifyZeroInteractions(mockLocalDataSource);
      });
    });
  });

  group('deleteLocalData', () {
    group('should handle exception', () {
      test('and return CleanFailure UNEXPECTED_ERROR', () async {
        when(mockLocalDataSource.delete(id: anyNamed('id')))
            .thenThrow(Exception());

        final result = await repo.deleteLocalData(id: '1');

        expect((result as Left).value,
            const CleanFailure(name: 'UNEXPECTED_ERROR'));
      });
      test('and return CleanFailure with expected values', () async {
        when(mockLocalDataSource.delete(id: anyNamed('id'))).thenThrow(
          const CleanException(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );

        final result = await repo.deleteLocalData(id: '1');

        expect(
          (result as Left).value,
          const CleanFailure(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );
      });

      test('should return NO_LOCAL_DATA_SOURCE', () async {
        repo = DataRepository(remoteQueryDataSource: mockRemoteDataSource);
        final result = await repo.deleteLocalData(id: '1');
        expect(
          (result as Left).value,
          const CleanFailure(name: 'NO_LOCAL_DATA_SOURCE'),
        );
      });

      group('should call localDataSource.delete', () {
        test('and do nothing again if no lastParams', () async {
          repo.cachedData = [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
          ];
          await repo.deleteLocalData(id: '1');
          verify(mockLocalDataSource.delete(id: '1'));
          verifyNoMoreInteractions(mockLocalDataSource);
          verifyZeroInteractions(mockRemoteDataSource);
        });
        group('and then query local again', () {
          test('with pageSize 1 if cachedData empty', () async {
            when(mockLocalDataSource.read(params: anyNamed('params')))
                .thenAnswer(
              (_) async => [
                _TestEntity('1', 'Orange'),
                _TestEntity('2', 'Strawberry'),
                _TestEntity('3', 'Pineapple'),
              ],
            );
            repo.cachedData = [
              _TestEntity('1', 'Orange'),
            ];
            repo.lastParams = _TestEntityQueryParams('abc');
            await repo.deleteLocalData(id: '3');
            verifyInOrder([
              mockLocalDataSource.delete(id: '3'),
              mockLocalDataSource.read(params: _TestEntityQueryParams('abc'))
            ]);
            expect(repo.cachedData, [
              _TestEntity('1', 'Orange'),
              _TestEntity('2', 'Strawberry'),
              _TestEntity('3', 'Pineapple'),
            ]);
            verifyZeroInteractions(mockRemoteDataSource);
          });
        });
      });
    });

    test('should call localDataSource.delete with id', () async {
      await repo.deleteLocalData(id: '1');
      verify(mockLocalDataSource.delete(id: '1'));
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test('should call localDataSource.delete without id', () async {
      await repo.deleteLocalData();
      verify(mockLocalDataSource.delete());
      verifyZeroInteractions(mockRemoteDataSource);
    });
  });
  group('putLocalData', () {
    final fixture = [_TestEntity('1', 'Apple')];
    group('should handle exception', () {
      test('and return CleanFailure UNEXPECTED_ERROR', () async {
        when(mockLocalDataSource.putAll(data: anyNamed('data')))
            .thenThrow(Exception());

        final result = await repo.putLocalData(data: fixture);

        expect((result as Left).value,
            const CleanFailure(name: 'UNEXPECTED_ERROR'));
      });
      test('and return CleanFailure with expected values', () async {
        when(mockLocalDataSource.putAll(data: anyNamed('data'))).thenThrow(
          const CleanException(
            name: 'TEST_ERROR',
            group: 'TEST',
            data: <String, dynamic>{'id': 1},
          ),
        );

        final result = await repo.putLocalData(data: fixture);

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

    test('should return NO_LOCAL_DATA_SOURCE', () async {
      repo = DataRepository(remoteQueryDataSource: mockRemoteDataSource);
      final result = await repo.putLocalData(data: fixture);
      expect(
        (result as Left).value,
        const CleanFailure(name: 'NO_LOCAL_DATA_SOURCE'),
      );
    });
    group('should call localDataSource.putAll', () {
      test('and do nothing again if no lastParams', () async {
        repo.cachedData = [
          _TestEntity('1', 'Orange'),
          _TestEntity('2', 'Strawberry'),
          _TestEntity('3', 'Pineapple'),
        ];
        await repo.putLocalData(data: fixture);
        verify(mockLocalDataSource.putAll(data: fixture));
        verifyNoMoreInteractions(mockLocalDataSource);
        verifyZeroInteractions(mockRemoteDataSource);
      });
      group('and then query local again', () {
        test('with pageSize 1 if cachedData empty', () async {
          when(mockLocalDataSource.read(params: anyNamed('params'))).thenAnswer(
            (_) async => [
              _TestEntity('1', 'Orange'),
              _TestEntity('2', 'Strawberry'),
              _TestEntity('3', 'Pineapple'),
            ],
          );
          repo.cachedData = [
            _TestEntity('1', 'Orange'),
          ];
          repo.lastParams = _TestEntityQueryParams('abc');
          await repo.putLocalData(data: fixture);
          verifyInOrder([
            mockLocalDataSource.putAll(data: fixture),
            mockLocalDataSource.read(params: _TestEntityQueryParams('abc'))
          ]);
          expect(repo.cachedData, [
            _TestEntity('1', 'Orange'),
            _TestEntity('2', 'Strawberry'),
            _TestEntity('3', 'Pineapple'),
          ]);
          verifyZeroInteractions(mockRemoteDataSource);
        });
      });
    });
  });
}
