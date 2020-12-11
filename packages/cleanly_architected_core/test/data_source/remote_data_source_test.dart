import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:cleanly_architected_core/src/platform/clean_api_client.dart';
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

class _TestEntityRemoteQueryDataSource
    extends RemoteQueryDataSource<_TestEntity, NoQueryParams<_TestEntity>> {
  _TestEntityRemoteQueryDataSource({CleanApiClient client})
      : super(client: client);
  @override
  Future<List<_TestEntity>> read({
    int pageSize,
    int pageNumber,
    NoQueryParams<_TestEntity> params,
  }) {
    throw UnimplementedError();
  }
}

class _TestEntityRemoteMutationDataSource extends RemoteMutationDataSource<
    _TestEntity, NoMutationParams<_TestEntity>> {
  _TestEntityRemoteMutationDataSource({CleanApiClient client})
      : super(client: client);
  @override
  Future<_TestEntity> create({NoMutationParams<_TestEntity> params}) {
    throw UnimplementedError();
  }

  @override
  Future<_TestEntity> update({NoMutationParams<_TestEntity> params}) {
    throw UnimplementedError();
  }
}

class _TestEntityRemoteDeletionDataSource extends RemoteDeletionDataSource<
    _TestEntity, NoDeletionParams<_TestEntity>> {
  _TestEntityRemoteDeletionDataSource({CleanApiClient client})
      : super(client: client);

  @override
  Future<void> delete({NoDeletionParams<_TestEntity> params}) {
    throw UnimplementedError();
  }
}

class MockClient extends Mock implements CleanApiClient {}

void main() {
  MockClient mockClient;
  setUp(() {
    mockClient = MockClient();
  });
  group('RemoteQueryDataSource', () {
    _TestEntityRemoteQueryDataSource dataSource;

    setUp(() {
      dataSource = _TestEntityRemoteQueryDataSource(client: mockClient);
    });

    test('client should be assigned', () {
      expect(dataSource.client, mockClient);
    });
  });
  group('RemoteMutationDataSource', () {
    _TestEntityRemoteMutationDataSource dataSource;

    setUp(() {
      dataSource = _TestEntityRemoteMutationDataSource(client: mockClient);
    });

    test('client should be assigned', () {
      expect(dataSource.client, mockClient);
    });
  });

  group('RemoteDeletionDataSource', () {
    _TestEntityRemoteDeletionDataSource dataSource;

    setUp(() {
      dataSource = _TestEntityRemoteDeletionDataSource(client: mockClient);
    });

    test('client should be assigned', () {
      expect(dataSource.client, mockClient);
    });
  });
}
