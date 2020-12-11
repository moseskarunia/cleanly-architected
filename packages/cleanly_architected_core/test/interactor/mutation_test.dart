import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/interactor/mutation.dart';
import 'package:cleanly_architected_core/src/repository/mutation_repository.dart';
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

class MockMutRepo extends Mock
    implements
        MutationRepository<_TestEntity, NoMutationParams<_TestEntity>,
            NoQueryParams<_TestEntity>> {}

void main() {
  final mParamsFixture = NoMutationParams<_TestEntity>();
  MockMutRepo mockRepo;

  setUp(() {
    mockRepo = MockMutRepo();
  });

  group('create', () {
    test('should call repo.create', () async {
      Create<_TestEntity, NoMutationParams<_TestEntity>,
          NoQueryParams<_TestEntity>> create = Create(repo: mockRepo);
      await create(params: mParamsFixture);
      verify(mockRepo.create(params: mParamsFixture));
    });
  });

  group('update', () {
    test('should call repo.update', () async {
      Update<_TestEntity, NoMutationParams<_TestEntity>,
          NoQueryParams<_TestEntity>> update = Update(repo: mockRepo);
      await update(params: mParamsFixture);
      verify(mockRepo.update(params: mParamsFixture));
    });
  });
}
