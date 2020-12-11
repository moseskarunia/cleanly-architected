import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/interactor/form.dart';
import 'package:cleanly_architected_core/src/repository/remote_mutation_repository.dart';
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

class MockRepo extends Mock
    implements
        RemoteMutationRepository<_TestEntity, NoFormParams<_TestEntity>> {}

void main() {
  final mParamsFixture = NoFormParams<_TestEntity>();
  MockRepo mockRepo;

  setUp(() {
    mockRepo = MockRepo();
  });

  group('create', () {
    test('should call repo.create', () async {
      Create<_TestEntity, NoFormParams<_TestEntity>> create =
          Create(repo: mockRepo);
      await create(params: mParamsFixture);
      verify(mockRepo.create(params: mParamsFixture));
    });
  });

  group('update', () {
    test('should call repo.update', () async {
      Update<_TestEntity, NoFormParams<_TestEntity>> update =
          Update(repo: mockRepo);
      await update(params: mParamsFixture);
      verify(mockRepo.update(params: mParamsFixture));
    });
  });

  group('delete', () {
    test('should call repo.delete', () async {
      Delete<_TestEntity, NoFormParams<_TestEntity>> delete =
          Delete(repo: mockRepo);
      await delete(id: '123');
      verify(mockRepo.delete(id: '123'));
    });
  });
}
