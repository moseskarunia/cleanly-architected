import 'package:bloc_test/bloc_test.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:cleanly_architected_state_manager_bloc/src/query_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class _TestEntity extends EquatableEntity {
  final String id;
  _TestEntity(this.id);

  @override
  List<Object> get props => [id];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  String get entityIdentifier => id;
}

// ignore: must_be_immutable
class MockQueryParams extends Mock implements QueryParams<_TestEntity> {}

class MockReadNext extends Mock
    implements ReadNext<_TestEntity, MockQueryParams> {}

class MockRefreshAll extends Mock
    implements RefreshAll<_TestEntity, MockQueryParams> {}

void main() {
  final fixtures = [
    _TestEntity('123'),
    _TestEntity('456'),
  ];
  final queryParamsFixture = MockQueryParams();
  MockReadNext mockReadNext;
  MockRefreshAll mockRefreshAll;
  QueryCubit<_TestEntity, MockQueryParams> _cubit;
  setUp(() {
    mockRefreshAll = MockRefreshAll();
    mockReadNext = MockReadNext();
    _cubit = QueryCubit(
      readNext: mockReadNext,
      refreshAll: mockRefreshAll,
    );
  });

  test('CleanQueryState', () {
    final state = QueryState<_TestEntity>();
    expect(state.props, [[], false, null, false, 0]);
    expect(state.isError, false);
  });

  group('readNext', () {
    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should do nothing when isLoading still true',
      build: () {
        return QueryCubit<_TestEntity, MockQueryParams>(
          readNext: mockReadNext,
          refreshAll: mockRefreshAll,
          initialState: QueryState<_TestEntity>(isLoading: true),
        );
      },
      act: (cubit) => cubit.readNext(pageSize: 10, params: queryParamsFixture),
      expect: [],
      verify: (_) {
        verifyZeroInteractions(mockReadNext);
      },
    );
    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should emit Failure',
      build: () {
        when(mockReadNext(
          params: anyNamed('params'),
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer(
            (_) async => Left(const CleanFailure(name: 'TEST_ERROR')));

        return _cubit;
      },
      act: (cubit) => cubit.readNext(pageSize: 10, params: queryParamsFixture),
      expect: [
        QueryState<_TestEntity>(isLoading: true),
        QueryState<_TestEntity>(
          failure: const CleanFailure(name: 'TEST_ERROR'),
        )
      ],
      verify: (_) {
        mockReadNext(params: queryParamsFixture, pageSize: 10, pageNumber: 1);
      },
    );

    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should emit data can clear previous failure',
      build: () {
        when(mockReadNext(
          params: anyNamed('params'),
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => Right(fixtures));

        return QueryCubit(
          readNext: mockReadNext,
          refreshAll: mockRefreshAll,
          initialState: QueryState(
            failure: const CleanFailure(name: 'TEST_ERROR'),
          ),
        );
      },
      act: (cubit) => cubit.readNext(pageSize: 3, params: queryParamsFixture),
      expect: [
        QueryState<_TestEntity>(
          isLoading: true,
          failure: const CleanFailure(name: 'TEST_ERROR'),
        ),
        QueryState<_TestEntity>(
          data: fixtures,
          endOfList: true,
        ),
      ],
      verify: (_) {
        mockReadNext(params: queryParamsFixture, pageSize: 3, pageNumber: 1);
      },
    );

    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should emit data with toPage',
      build: () {
        when(mockReadNext(
          params: anyNamed('params'),
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => Right(fixtures));

        return _cubit;
      },
      act: (cubit) => cubit.readNext(
        pageSize: 3,
        params: queryParamsFixture,
        toPage: 2,
      ),
      expect: [
        QueryState<_TestEntity>(isLoading: true),
        QueryState<_TestEntity>(
          data: fixtures,
          endOfList: true,
        ),
      ],
      verify: (_) {
        mockReadNext(params: queryParamsFixture, pageSize: 3, pageNumber: 2);
      },
    );

    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should emit old data if error',
      build: () {
        when(mockReadNext(
          params: anyNamed('params'),
          pageNumber: anyNamed('pageNumber'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer(
            (_) async => Left(const CleanFailure(name: 'TEST_ERROR')));

        return QueryCubit(
          readNext: mockReadNext,
          refreshAll: mockRefreshAll,
          initialState: QueryState(data: fixtures),
        );
      },
      act: (cubit) => cubit.readNext(pageSize: 10, params: queryParamsFixture),
      expect: [
        QueryState<_TestEntity>(data: fixtures, isLoading: true),
        QueryState<_TestEntity>(
          data: fixtures,
          failure: const CleanFailure(name: 'TEST_ERROR'),
        ),
      ],
      verify: (_) {
        mockReadNext(params: queryParamsFixture, pageSize: 10, pageNumber: 1);
      },
    );
  });

  group('refreshAll', () {
    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should do nothing when isLoading still true',
      build: () {
        return QueryCubit<_TestEntity, MockQueryParams>(
          readNext: mockReadNext,
          refreshAll: mockRefreshAll,
          initialState: QueryState<_TestEntity>(isLoading: true),
        );
      },
      act: (cubit) => cubit.refreshAll(
        pageSize: 10,
        params: queryParamsFixture,
      ),
      expect: [],
      verify: (_) {
        verifyZeroInteractions(mockRefreshAll);
      },
    );

    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should emit Failure',
      build: () {
        when(mockRefreshAll(
          params: anyNamed('params'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer(
            (_) async => Left(const CleanFailure(name: 'TEST_ERROR')));

        return _cubit;
      },
      act: (cubit) =>
          cubit.refreshAll(pageSize: 10, params: queryParamsFixture),
      expect: [
        QueryState<_TestEntity>(isLoading: true),
        QueryState<_TestEntity>(
          failure: const CleanFailure(name: 'TEST_ERROR'),
        )
      ],
      verify: (_) {
        mockRefreshAll(params: queryParamsFixture, pageSize: 10);
      },
    );

    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should emit data, clear failure, and start from page 1',
      build: () {
        when(mockRefreshAll(
          params: anyNamed('params'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => Right(fixtures));

        return QueryCubit(
          readNext: mockReadNext,
          refreshAll: mockRefreshAll,
          initialState: QueryState<_TestEntity>(
            pageNumber: 3,
            data: fixtures,
            failure: const CleanFailure(name: 'TEST_ERROR'),
          ),
        );
      },
      act: (cubit) => cubit.refreshAll(pageSize: 3, params: queryParamsFixture),
      expect: [
        QueryState<_TestEntity>(
          data: fixtures,
          isLoading: true,
          pageNumber: 3,
          failure: const CleanFailure(name: 'TEST_ERROR'),
        ),
        QueryState<_TestEntity>(
          pageNumber: 1,
          data: fixtures,
          endOfList: true,
        ),
      ],
      verify: (_) {
        mockRefreshAll(params: queryParamsFixture, pageSize: 3);
      },
    );

    blocTest<QueryCubit<_TestEntity, MockQueryParams>, QueryState<_TestEntity>>(
      'should emit old data if error',
      build: () {
        when(mockRefreshAll(
          params: anyNamed('params'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer(
            (_) async => Left(const CleanFailure(name: 'TEST_ERROR')));

        return QueryCubit(
          readNext: mockReadNext,
          refreshAll: mockRefreshAll,
          initialState: QueryState(data: fixtures),
        );
      },
      act: (cubit) =>
          cubit.refreshAll(pageSize: 10, params: queryParamsFixture),
      expect: [
        QueryState<_TestEntity>(data: fixtures, isLoading: true),
        QueryState<_TestEntity>(
          data: fixtures,
          failure: const CleanFailure(name: 'TEST_ERROR'),
        ),
      ],
      verify: (_) {
        mockRefreshAll(params: queryParamsFixture, pageSize: 10);
      },
    );
  });
}
