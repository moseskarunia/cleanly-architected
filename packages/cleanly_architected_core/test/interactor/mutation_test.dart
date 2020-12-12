import 'package:cleanly_architected_core/cleanly_architected_core.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/interactor/mutation_interactors.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  const _TestEntity(String id) : super(id);

  @override
  List<Object> get props => [];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class MockMutationRepo extends Mock
    implements
        RemoteMutationRepository<_TestEntity, NoFormParams<_TestEntity>> {}

class MockDataRepo extends Mock
    implements DataRepository<_TestEntity, NoQueryParams<_TestEntity>> {}

void main() {
  final mParamsFixture = NoFormParams<_TestEntity>();
  MockMutationRepo mockMutRepo;
  MockDataRepo mockDataRepo;

  setUp(() {
    mockMutRepo = MockMutationRepo();
    mockDataRepo = MockDataRepo();
  });

  group('create should call mutationRepo.create', () {
    test('and return Failure', () async {
      Create<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          create = Create(mutationRepo: mockMutRepo, dataRepo: mockDataRepo);

      when(mockMutRepo.create(params: anyNamed('params'))).thenAnswer(
          (_) async => const Left(CleanFailure(name: 'TEST_ERROR')));

      final result = await create(params: mParamsFixture);

      expect((result as Left).value, const CleanFailure(name: 'TEST_ERROR'));

      verify(mockMutRepo.create(params: mParamsFixture));
      verifyZeroInteractions(mockDataRepo);
    });

    test('without putting data to local', () async {
      when(mockMutRepo.create(params: anyNamed('params')))
          .thenAnswer((_) async => Right(_TestEntity('123')));

      Create<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          create = Create(mutationRepo: mockMutRepo);
      final result = await create(params: mParamsFixture);
      expect((result as Right).value, _TestEntity('123'));
      verify(mockMutRepo.create(params: mParamsFixture));
      verifyZeroInteractions(mockDataRepo);
    });

    test('and put the result to local', () async {
      when(mockMutRepo.create(params: anyNamed('params')))
          .thenAnswer((_) async => Right(_TestEntity('123')));

      Create<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          create = Create(mutationRepo: mockMutRepo, dataRepo: mockDataRepo);

      final result = await create(params: mParamsFixture);
      expect((result as Right).value, _TestEntity('123'));
      verifyInOrder([
        mockMutRepo.create(params: mParamsFixture),
        mockDataRepo.putLocalData(data: [_TestEntity('123')])
      ]);
    });
  });

  group('update should call mutationRepo.update', () {
    test('and return Failure', () async {
      Update<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          update = Update(mutationRepo: mockMutRepo, dataRepo: mockDataRepo);

      when(mockMutRepo.update(params: anyNamed('params'))).thenAnswer(
          (_) async => const Left(CleanFailure(name: 'TEST_ERROR')));

      final result = await update(params: mParamsFixture);

      expect((result as Left).value, const CleanFailure(name: 'TEST_ERROR'));

      verify(mockMutRepo.update(params: mParamsFixture));
      verifyZeroInteractions(mockDataRepo);
    });

    test('without putting data to local', () async {
      when(mockMutRepo.update(params: anyNamed('params')))
          .thenAnswer((_) async => Right(_TestEntity('123')));

      Update<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          update = Update(mutationRepo: mockMutRepo);
      final result = await update(params: mParamsFixture);
      expect((result as Right).value, _TestEntity('123'));
      verify(mockMutRepo.update(params: mParamsFixture));
      verifyZeroInteractions(mockDataRepo);
    });

    test('and put the result to local', () async {
      when(mockMutRepo.update(params: anyNamed('params')))
          .thenAnswer((_) async => Right(_TestEntity('123')));

      Update<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          update = Update(mutationRepo: mockMutRepo, dataRepo: mockDataRepo);

      final result = await update(params: mParamsFixture);
      expect((result as Right).value, _TestEntity('123'));
      verifyInOrder([
        mockMutRepo.update(params: mParamsFixture),
        mockDataRepo.putLocalData(data: [_TestEntity('123')])
      ]);
    });
  });

  group('delete should call mutationRepo.delete', () {
    test('and return Failure', () async {
      Delete<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          delete = Delete(mutationRepo: mockMutRepo, dataRepo: mockDataRepo);

      when(mockMutRepo.delete(id: anyNamed('id'))).thenAnswer(
          (_) async => const Left(CleanFailure(name: 'TEST_ERROR')));

      final result = await delete(id: '123');

      expect((result as Left).value, const CleanFailure(name: 'TEST_ERROR'));

      verify(mockMutRepo.delete(id: '123'));
      verifyZeroInteractions(mockDataRepo);
    });

    test('without deleting local data', () async {
      when(mockMutRepo.delete(id: anyNamed('id')))
          .thenAnswer((_) async => Right(unit));

      Delete<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          delete = Delete(mutationRepo: mockMutRepo);
      final result = await delete(id: '123');
      expect((result as Right).value, unit);
      verify(mockMutRepo.delete(id: '123'));
      verifyZeroInteractions(mockDataRepo);
    });

    test('and delete from local as well', () async {
      when(mockMutRepo.delete(id: anyNamed('id')))
          .thenAnswer((_) async => Right(unit));

      Delete<_TestEntity, NoFormParams<_TestEntity>, NoQueryParams<_TestEntity>>
          delete = Delete(mutationRepo: mockMutRepo, dataRepo: mockDataRepo);

      final result = await delete(id: '123');
      expect((result as Right).value, unit);
      verifyInOrder([
        mockMutRepo.delete(id: '123'),
        mockDataRepo.deleteLocalData(id: '123')
      ]);
    });
  });
}
