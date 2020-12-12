import 'package:bloc_test/bloc_test.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:cleanly_architected_state_manager_bloc/src/clean_query_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class _TestEntity extends EquatableEntity {
  _TestEntity(String id) : super(id);

  @override
  List<Object> get props => throw UnimplementedError();

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

// ignore: must_be_immutable
class MockQueryParams extends Mock implements QueryParams<_TestEntity> {}

class MockReadNext extends Mock
    implements ReadNext<_TestEntity, MockQueryParams> {}

class MockRefreshAll extends Mock
    implements RefreshAll<_TestEntity, MockQueryParams> {}

void main() {
  final queryParamsFixture = MockQueryParams();
  MockReadNext mockReadNext;
  MockRefreshAll mockRefreshAll;
  CleanQueryCubit _cubit;
  setUp(() {
    mockRefreshAll = MockRefreshAll();
    mockReadNext = MockReadNext();
    _cubit = CleanQueryCubit(
      readNext: mockReadNext,
      refreshAll: mockRefreshAll,
    );
  });

  test('CleanQueryState', () {
    final state = CleanQueryState<_TestEntity>();
    expect(state.props, [[], false, null, false, 0]);
  });

  group('readNext', () {
    blocTest<CleanQueryCubit<_TestEntity, MockQueryParams>,
        CleanQueryState<_TestEntity>>(
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
      expect: [],
      verify: (_) {
        mockReadNext(params: queryParamsFixture, pageSize: 10, pageNumber: 1);
      },
    );
  });

  group('refreshAll', () {
    setUp(() {});
  });
}
