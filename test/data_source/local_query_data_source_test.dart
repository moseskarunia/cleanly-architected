import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:cleanly_architected/src/platform/clean_local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  final String name;

  const _TestEntity({String id, this.name}) : super(id);

  @override
  List<Object> get props => [id, name];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};
}

class _TestEntityLocalQueryDataSource
    extends LocalQueryDataSource<_TestEntity, NoQueryParams<_TestEntity>> {
  const _TestEntityLocalQueryDataSource({@required CleanLocalStorage storage})
      : super(storage: storage);

  @override
  Future<void> delete({String key}) {
    throw UnimplementedError();
  }

  @override
  Future<List<_TestEntity>> read({NoQueryParams<_TestEntity> params}) {
    throw UnimplementedError();
  }
}

class MockStorage extends Mock implements CleanLocalStorage {}

void main() {
  final fixtures = [
    _TestEntity(id: '1', name: 'Apple'),
    _TestEntity(id: '2', name: 'Orange'),
    _TestEntity(id: '3', name: 'Grape'),
    _TestEntity(id: '4', name: 'Pineapple'),
    _TestEntity(id: '5', name: 'Banana'),
  ];
  MockStorage mockStorage;
  _TestEntityLocalQueryDataSource dataSource;

  setUp(() {
    mockStorage = MockStorage();
    dataSource = _TestEntityLocalQueryDataSource(storage: mockStorage);
  });

  group('putAll', () {
    test('should not do anything if storage null', () async {
      await dataSource.putAll(data: [...fixtures]);
      verifyZeroInteractions(mockStorage);
    });

    test('should exclude data which id returns null', () async {});
    test('should exclude data which toJson returns null', () async {});
    test('should putAll data to storage', () async {});
  });
}
