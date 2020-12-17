import 'package:bloc_test/bloc_test.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:cleanly_architected_state_manager_bloc/src/deletion_cubit.dart';
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
class MockFormParams extends Mock implements FormParams<_TestEntity> {}

// ignore: must_be_immutable
class MockQueryParams extends Mock implements QueryParams<_TestEntity> {}

class MockDelete extends Mock
    implements Delete<_TestEntity, MockFormParams, MockQueryParams> {}

void main() {
  MockDelete mockDelete;

  setUp(() {
    mockDelete = MockDelete();
  });

  test('DeletionState.props', () {
    final s = DeletionState(failure: const CleanFailure(name: 'TEST_ERROR'));

    expect(s.props, [const CleanFailure(name: 'TEST_ERROR'), false, false]);
  });

  group('delete', () {
    blocTest<DeletionCubit<_TestEntity, MockFormParams, MockQueryParams>,
        DeletionState<_TestEntity>>(
      'should not emit anything if isLoading',
      build: () {
        return DeletionCubit(
          delete: mockDelete,
          initialState: DeletionState<_TestEntity>(isLoading: true),
        );
      },
      act: (cubit) => cubit.delete(id: '123'),
      expect: [],
      verify: (_) {
        verifyZeroInteractions(mockDelete);
      },
    );
    blocTest<DeletionCubit<_TestEntity, MockFormParams, MockQueryParams>,
        DeletionState<_TestEntity>>(
      'should emit failure and set !isSuccessful',
      build: () {
        when(mockDelete(id: anyNamed('id'))).thenAnswer(
            (_) async => Left(const CleanFailure(name: 'TEST_ERROR')));

        return DeletionCubit(
          delete: mockDelete,
          initialState: DeletionState<_TestEntity>(isSuccessful: true),
        );
      },
      act: (cubit) => cubit.delete(id: '123'),
      expect: [
        DeletionState<_TestEntity>(isLoading: true),
        DeletionState<_TestEntity>(
          isSuccessful: false,
          failure: const CleanFailure(name: 'TEST_ERROR'),
        ),
      ],
      verify: (cubit) {
        expect(cubit.state.isSuccessful, false);
        expect(cubit.state.isError, true);
        verify(mockDelete(id: '123'));
      },
    );

    blocTest<DeletionCubit<_TestEntity, MockFormParams, MockQueryParams>,
        DeletionState<_TestEntity>>(
      'should emit isSuccessful and clear previous failure',
      build: () {
        when(mockDelete(id: anyNamed('id')))
            .thenAnswer((_) async => Right(unit));

        return DeletionCubit(
          delete: mockDelete,
          initialState: DeletionState<_TestEntity>(
            isSuccessful: false,
            failure: const CleanFailure(name: 'TEST_ERROR'),
          ),
        );
      },
      act: (cubit) => cubit.delete(id: '123'),
      expect: [
        DeletionState<_TestEntity>(
          isLoading: true,
          failure: const CleanFailure(name: 'TEST_ERROR'),
        ),
        DeletionState<_TestEntity>(isSuccessful: true),
      ],
      verify: (cubit) {
        expect(cubit.state.isSuccessful, true);
        expect(cubit.state.isError, false);
        verify(mockDelete(id: '123'));
      },
    );
  });
}
