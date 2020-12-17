import 'package:cleanly_architected_core/src/data_source/local_data_source.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/platform/clean_local_storage.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  final String name;
  final String id;

  const _TestEntity({this.id, this.name});

  @override
  List<Object> get props => [entityIdentifier, name];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};

  @override
  // TODO: implement entityIdentifier
  String get entityIdentifier => id;
}

class _MutationParams extends FormParams<_TestEntity> {
  final String name;
  final bool isActive;

  _MutationParams({this.name, this.isActive});

  @override
  List<Object> get props => [name, isActive];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'isActive': isActive,
      };
}

class _TestEntityLocalFormCacheDataSource
    extends LocalFormCacheDataSource<_TestEntity, _MutationParams> {
  const _TestEntityLocalFormCacheDataSource({CleanLocalStorage storage})
      : super(storage: storage, storageName: 'test-form-storage');

  @override
  Future<_MutationParams> read() {
    throw UnimplementedError();
  }
}

class _TestEntityLocalFormCacheDataSource2
    extends LocalFormCacheDataSource<_TestEntity, _MutationParams> {
  const _TestEntityLocalFormCacheDataSource2({CleanLocalStorage storage})
      : super(storage: storage);

  @override
  Future<_MutationParams> read() {
    throw UnimplementedError();
  }
}

class _TestEntityLocalFormCacheDataSource3
    extends LocalFormCacheDataSource<_TestEntity, _MutationParams> {
  const _TestEntityLocalFormCacheDataSource3({CleanLocalStorage storage})
      : super(storage: storage, storageName: '');

  @override
  Future<_MutationParams> read() {
    throw UnimplementedError();
  }
}

class MockStorage extends Mock implements CleanLocalStorage {}

void main() {
  MockStorage mockStorage;
  _TestEntityLocalFormCacheDataSource dataSource;

  setUp(() {
    mockStorage = MockStorage();
    dataSource = _TestEntityLocalFormCacheDataSource(storage: mockStorage);
  });

  test('storage should be assigned', () {
    expect(dataSource.storage, mockStorage);
  });

  group('putAll', () {
    group('should not do anything if ', () {
      test('storageName null', () async {
        final dataSource2 =
            _TestEntityLocalFormCacheDataSource2(storage: mockStorage);
        await dataSource2.putAll(
          data: _MutationParams(name: 'Apple', isActive: true),
        );
        verifyZeroInteractions(mockStorage);
      });
      test('storageName empty', () async {
        final dataSource3 =
            _TestEntityLocalFormCacheDataSource3(storage: mockStorage);
        await dataSource3.putAll(
          data: _MutationParams(name: 'Apple', isActive: true),
        );
        verifyZeroInteractions(mockStorage);
      });
      test('storage null', () async {
        dataSource = _TestEntityLocalFormCacheDataSource(storage: null);
        await dataSource.putAll(
          data: _MutationParams(name: 'Apple', isActive: true),
        );
        verifyZeroInteractions(mockStorage);
      });
    });

    test('should putAll data to storage', () async {
      final params = _MutationParams(name: 'Apple', isActive: true);
      await dataSource.putAll(data: params);

      verify(mockStorage.putAll(
        storageName: 'test-form-storage',
        data: params.toJson(),
      ));
    });
  });

  group('delete', () {
    test('should call storage.delete', () async {
      await dataSource.delete();
      verify(mockStorage.delete(storageName: 'test-form-storage'));
    });
  });
}
