import 'dart:math';

import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:cleanly_architected/src/repository/mutation_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class _TestEntity extends EquatableEntity {
  final String name;

  const _TestEntity(String id, this.name) : super(id);

  @override
  List<Object> get props => [id, name];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class _TestEntityMutationParams extends MutationParams<_TestEntity> {
  final String name;

  _TestEntityMutationParams(this.name);
  @override
  List<Object> get props => [name];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class _TestEntityDeletionParams extends DeletionParams<_TestEntity> {
  final String name;

  _TestEntityDeletionParams(this.name);
  @override
  List<Object> get props => [name];
}

class MockLocalMutationDataSource extends Mock
    implements
        LocalMutationDataSource<_TestEntity, _TestEntityMutationParams> {}

class MockRemoteMutationDataSource extends Mock
    implements
        RemoteMutationDataSource<_TestEntity, _TestEntityMutationParams,
            _TestEntityDeletionParams> {}

void main() {
  MockLocalMutationDataSource mockLocalDataSource;
  MockRemoteMutationDataSource mockRemoteDataSource;
  MutationRepository<_TestEntity, _TestEntityMutationParams,
      _TestEntityDeletionParams> repo;

  setUp(() {
    mockLocalDataSource = MockLocalMutationDataSource();
    mockRemoteDataSource = MockRemoteMutationDataSource();
    repo = MutationRepository(
      localDataSource: mockLocalDataSource,
      remoteMutationDataSource: mockRemoteDataSource,
    );
  });

  test('should assign data sources correctly', () {
    expect(repo.localDataSource, mockLocalDataSource);
    expect(repo.remoteMutationDataSource, mockRemoteDataSource);
  });
}
