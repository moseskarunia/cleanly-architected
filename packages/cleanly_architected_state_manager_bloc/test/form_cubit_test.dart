import 'package:bloc_test/bloc_test.dart';
import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:cleanly_architected_state_manager_bloc/src/form_cubit.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class _TestEntity extends EquatableEntity {
  _TestEntity(String id) : super(id);

  @override
  List<Object> get props => [id];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

// ignore: must_be_immutable
class MockFormParams extends Mock implements FormParams<_TestEntity> {}

// ignore: must_be_immutable
class MockQueryParams extends Mock implements QueryParams<_TestEntity> {}

class MockCreate extends Mock
    implements Create<_TestEntity, MockFormParams, MockQueryParams> {}

class MockUpdate extends Mock
    implements Update<_TestEntity, MockFormParams, MockQueryParams> {}

void main() {
  MockFormParams mockFormParams;
  MockQueryParams mockQueryParams;
  MockCreate mockCreate;
  MockUpdate mockUpdate;

  setUp(() {
    mockFormParams = MockFormParams();
    mockQueryParams = MockQueryParams();
    mockCreate = MockCreate();
    mockUpdate = MockUpdate();
  });

  test('FormState', () {
    final s = FormState<_TestEntity>(
      failure: const CleanFailure(name: 'TEST_ERROR'),
    );
    expect(s.props, [null, const CleanFailure(name: 'TEST_ERROR'), false]);
    expect(s.isError, true);
    expect(s.isSuccessful, false);
  });

  group('CreateFormCubit', () {
    CreateFormCubit<_TestEntity, MockFormParams, MockQueryParams> _cubit;

    setUp(() {
      _cubit = CreateFormCubit(create: mockCreate);
    });

    group('create', () {
      blocTest<CreateFormCubit<_TestEntity, MockFormParams, MockQueryParams>,
          FormState<_TestEntity>>(
        'should not emit anything if isLoading',
        build: () {
          return CreateFormCubit(
            create: mockCreate,
            initialState: FormState(isLoading: true),
          );
        },
        act: (cubit) => cubit.create(params: mockFormParams),
        expect: [],
        verify: (_) {
          verifyZeroInteractions(mockCreate);
        },
      );

      blocTest<CreateFormCubit<_TestEntity, MockFormParams, MockQueryParams>,
          FormState<_TestEntity>>(
        'should emit failure but still retain old data',
        build: () {
          when(mockCreate(params: anyNamed('params'))).thenAnswer(
              (_) async => Left(const CleanFailure(name: 'TEST_ERROR')));

          return CreateFormCubit(
            create: mockCreate,
            initialState: FormState(data: _TestEntity('987')),
          );
        },
        act: (cubit) => cubit.create(params: mockFormParams),
        expect: [
          FormState<_TestEntity>(data: _TestEntity('987'), isLoading: true),
          FormState<_TestEntity>(
            data: _TestEntity('987'),
            failure: const CleanFailure(name: 'TEST_ERROR'),
          ),
        ],
        verify: (cubit) {
          expect(cubit.state.isError, true);
          expect(cubit.state.isSuccessful, false);
          verify(mockCreate(params: mockFormParams));
        },
      );

      blocTest<CreateFormCubit<_TestEntity, MockFormParams, MockQueryParams>,
          FormState<_TestEntity>>(
        'should emit data for successful operation',
        build: () {
          when(mockCreate(params: anyNamed('params')))
              .thenAnswer((_) async => Right(_TestEntity('987')));

          return _cubit;
        },
        act: (cubit) => cubit.create(params: mockFormParams),
        expect: [
          FormState<_TestEntity>(isLoading: true),
          FormState<_TestEntity>(data: _TestEntity('987')),
        ],
        verify: (cubit) {
          expect(cubit.state.isError, false);
          expect(cubit.state.isSuccessful, true);
          verify(mockCreate(params: mockFormParams));
        },
      );
    });
  });

  group('UpdateFormCubit', () {});
}
