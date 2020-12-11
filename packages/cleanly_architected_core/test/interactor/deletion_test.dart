import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/interactor/mutation.dart';
import 'package:cleanly_architected_core/src/repository/deletion_repository.dart';
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

class MockDelRepo extends Mock
    implements DeletionRepository<_TestEntity, NoDeletionParams<_TestEntity>> {}

void main() {
  final dParamsFixture = NoDeletionParams<_TestEntity>();
  MockDelRepo mockDelRepo;

  setUp(() {
    mockDelRepo = MockDelRepo();
  });
  test('should call repo.delete', () async {
    Delete<_TestEntity, NoDeletionParams<_TestEntity>> delete =
        Delete(repo: mockDelRepo);
    await delete(params: dParamsFixture);
    verify(mockDelRepo.delete(params: dParamsFixture));
  });
}
