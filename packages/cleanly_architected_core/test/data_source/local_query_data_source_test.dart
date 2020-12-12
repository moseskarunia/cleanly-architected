import 'package:cleanly_architected_core/src/data_source/local_data_source.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/platform/clean_local_storage.dart';
import 'package:test/test.dart';
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
    extends LocalDataSource<_TestEntity, NoQueryParams<_TestEntity>> {
  const _TestEntityLocalQueryDataSource({CleanLocalStorage storage})
      : super(storage: storage, storageName: 'test-storage');

  @override
  Future<List<_TestEntity>> read({NoQueryParams<_TestEntity> params}) {
    throw UnimplementedError();
  }
}

class _TestEntityLocalQueryDataSource2
    extends LocalDataSource<_TestEntity, NoQueryParams<_TestEntity>> {
  const _TestEntityLocalQueryDataSource2({CleanLocalStorage storage})
      : super(storage: storage);

  @override
  Future<List<_TestEntity>> read({NoQueryParams<_TestEntity> params}) {
    throw UnimplementedError();
  }
}

class _TestEntityLocalQueryDataSource3
    extends LocalDataSource<_TestEntity, NoQueryParams<_TestEntity>> {
  const _TestEntityLocalQueryDataSource3({CleanLocalStorage storage})
      : super(storage: storage, storageName: '');

  @override
  Future<List<_TestEntity>> read({NoQueryParams<_TestEntity> params}) {
    throw UnimplementedError();
  }
}

class MockStorage extends Mock implements CleanLocalStorage {}

void main() {
  MockStorage mockStorage;
  _TestEntityLocalQueryDataSource dataSource;

  setUp(() {
    mockStorage = MockStorage();
    dataSource = _TestEntityLocalQueryDataSource(storage: mockStorage);
  });

  test('storage should be assigned', () {
    expect(dataSource.storage, mockStorage);
  });

  group('putAll', () {
    group('should not do anything if ', () {
      test('storageName null', () async {
        final dataSource2 =
            _TestEntityLocalQueryDataSource2(storage: mockStorage);
        await dataSource2.putAll(data: []);
        verifyZeroInteractions(mockStorage);
      });
      test('storageName empty', () async {
        final dataSource3 =
            _TestEntityLocalQueryDataSource3(storage: mockStorage);
        await dataSource3.putAll(data: []);
        verifyZeroInteractions(mockStorage);
      });
      test('storage null', () async {
        dataSource = _TestEntityLocalQueryDataSource(storage: null);
        await dataSource.putAll(data: []);
        verifyZeroInteractions(mockStorage);
      });
    });

    test('should exclude data which id returns null', () async {
      final fixtures = [
        _TestEntity(id: null, name: 'Apple'),
        _TestEntity(id: '2', name: 'Orange'),
        _TestEntity(id: null, name: 'Grape'),
        _TestEntity(id: '4', name: 'Pineapple'),
        _TestEntity(id: null, name: 'Banana'),
      ];

      await dataSource.putAll(data: fixtures);

      verify(mockStorage.putAll(storageName: 'test-storage', data: {
        '2': {'id': '2', 'name': 'Orange'},
        '4': {'id': '4', 'name': 'Pineapple'}
      }));
    });
    test('should putAll data to storage', () async {
      final fixtures = [
        _TestEntity(id: '1', name: 'Apple'),
        _TestEntity(id: '2', name: 'Orange'),
        _TestEntity(id: '3', name: 'Grape'),
        _TestEntity(id: '4', name: 'Pineapple'),
        _TestEntity(id: '5', name: 'Banana'),
      ];
      await dataSource.putAll(data: fixtures);

      verify(mockStorage.putAll(storageName: 'test-storage', data: {
        '1': {'id': '1', 'name': 'Apple'},
        '2': {'id': '2', 'name': 'Orange'},
        '3': {'id': '3', 'name': 'Grape'},
        '4': {'id': '4', 'name': 'Pineapple'},
        '5': {'id': '5', 'name': 'Banana'}
      }));
    });
  });

  group('delete', () {
    test('should call storage.delete', () async {
      await dataSource.delete(id: '1');
      verify(mockStorage.delete(storageName: 'test-storage', key: '1'));
    });
  });
}
