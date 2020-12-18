import 'package:cleanly_architected_core/src/data_source/params.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
import 'package:test/test.dart';

class _TestEntity extends EquatableEntity {
  final String name;
  final String id;

  const _TestEntity({this.id, this.name});

  @override
  List<Object> get props => [entityIdentifier, name];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};

  @override
  String get entityIdentifier => id;
}

class _TestEntityRemoteMutationDataSource
    extends RemoteMutationDataSource<_TestEntity, NoFormParams<_TestEntity>> {
  _TestEntityRemoteMutationDataSource();
}

void main() {
  group('RemoteMutationDataSource', () {
    _TestEntityRemoteMutationDataSource dataSource;

    setUp(() {
      dataSource = _TestEntityRemoteMutationDataSource();
    });

    test('create by default should throw UnimplementedError', () async {
      expectLater(
        () => dataSource.create(params: NoFormParams<_TestEntity>()),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('update by default should throw UnimplementedError', () async {
      expectLater(
        () => dataSource.update(params: NoFormParams<_TestEntity>()),
        throwsA(isA<UnimplementedError>()),
      );
    });

    test('delete by default should throw UnimplementedError', () async {
      expectLater(
        () => dataSource.delete(),
        throwsA(isA<UnimplementedError>()),
      );
    });
  });
}
