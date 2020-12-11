import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/interactor/query.dart';
import 'package:cleanly_architected_core/src/repository/query_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  const _TestEntity(String id) : super(id);

  @override
  // TODO: implement props
  List<Object> get props => [];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class _TestEntityQParams extends QueryParams<_TestEntity> {
  @override
  List<Object> get props => [];
}

class MockRepo extends Mock
    implements QueryRepository<_TestEntity, _TestEntityQParams> {}

void main() {
  MockRepo mockRepo;

  setUp(() {
    mockRepo = MockRepo();
  });

  group('readNext', () {
    ReadNext<_TestEntity, _TestEntityQParams> readNext;

    test('should call repo', () async {
      readNext = ReadNext(repo: mockRepo);

      await readNext(
        pageNumber: 1,
        pageSize: 10,
        params: _TestEntityQParams(),
      );

      verify(mockRepo.readNext(
        pageNumber: 1,
        pageSize: 10,
        params: _TestEntityQParams(),
      ));
    });
  });

  group('refreshAll', () {
    RefreshAll<_TestEntity, _TestEntityQParams> refreshAll;

    test('should call repo', () async {
      refreshAll = RefreshAll(repo: mockRepo);

      await refreshAll(
        pageSize: 10,
        params: _TestEntityQParams(),
      );

      verify(mockRepo.refreshAll(
        pageSize: 10,
        params: _TestEntityQParams(),
      ));
    });
  });
}
