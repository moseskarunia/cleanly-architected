import 'package:cleanly_architected_core/src/data_source/local_data_source.dart';
import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/platform/clean_local_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  final String name;

  const _TestEntity({String id, this.name}) : super(id);

  @override
  List<Object> get props => [id, name];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};
}

class _MutationParams extends MutationParams<_TestEntity> {
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

class _TestEntityLocalMutationDataSource
    extends LocalMutationDataSource<_TestEntity, _MutationParams> {
  const _TestEntityLocalMutationDataSource({CleanLocalStorage storage})
      : super(storage: storage, storageName: 'test-form-storage');

  @override
  Future<void> delete({String key}) {
    throw UnimplementedError();
  }

  @override
  Future<List<_TestEntity>> read({_MutationParams params}) {
    throw UnimplementedError();
  }
}

class _TestEntityLocalMutationDataSource2
    extends LocalMutationDataSource<_TestEntity, _MutationParams> {
  const _TestEntityLocalMutationDataSource2({CleanLocalStorage storage})
      : super(storage: storage);

  @override
  Future<void> delete({String key}) {
    throw UnimplementedError();
  }

  @override
  Future<List<_TestEntity>> read({_MutationParams params}) {
    throw UnimplementedError();
  }
}

class _TestEntityLocalMutationDataSource3
    extends LocalMutationDataSource<_TestEntity, _MutationParams> {
  const _TestEntityLocalMutationDataSource3({CleanLocalStorage storage})
      : super(storage: storage, storageName: '');

  @override
  Future<void> delete({String key}) {
    throw UnimplementedError();
  }

  @override
  Future<List<_TestEntity>> read({_MutationParams params}) {
    throw UnimplementedError();
  }
}

class MockStorage extends Mock implements CleanLocalStorage {}

void main() {
  MockStorage mockStorage;
  _TestEntityLocalMutationDataSource dataSource;

  setUp(() {
    mockStorage = MockStorage();
    dataSource = _TestEntityLocalMutationDataSource(storage: mockStorage);
  });

  test('storage should be assigned', () {
    expect(dataSource.storage, mockStorage);
  });

  group('putAll', () {
    group('should not do anything if ', () {
      test('storageName null', () async {
        final dataSource2 =
            _TestEntityLocalMutationDataSource2(storage: mockStorage);
        await dataSource2.putAll(
          data: _MutationParams(name: 'Apple', isActive: true),
        );
        verifyZeroInteractions(mockStorage);
      });
      test('storageName empty', () async {
        final dataSource3 =
            _TestEntityLocalMutationDataSource3(storage: mockStorage);
        await dataSource3.putAll(
          data: _MutationParams(name: 'Apple', isActive: true),
        );
        verifyZeroInteractions(mockStorage);
      });
      test('storage null', () async {
        dataSource = _TestEntityLocalMutationDataSource(storage: null);
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
}
