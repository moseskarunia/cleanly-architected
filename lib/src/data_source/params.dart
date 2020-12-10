import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:equatable/equatable.dart';

/// Query parameters of [RemoteQueryDataSource]'s [read].
abstract class QueryParams<T extends EquatableEntity> extends Equatable {
  const QueryParams();
}

/// Use this class if you don't need to add anything to the [QueryParams]
class NoQueryParams<T extends EquatableEntity> extends QueryParams<T> {
  const NoQueryParams();
  @override
  List<Object> get props => [];
}

/// Mutation parameters of [RemoteMutationDataSource]'s [create] and [update].
abstract class MutationParams<T extends EquatableEntity> extends Equatable {
  /// Will be used as key in [LocalMutationDataSource]'s putAll
  String get id;

  const MutationParams();

  /// Will be used as key in [LocalMutationDataSource]'s putAll
  Map<String, dynamic> toJson();
}

/// Use this class if you don't need to add anything to the [MutationParams]
class NoMutationParams<T extends EquatableEntity> extends MutationParams<T> {
  @override
  List<Object> get props => [];

  @override
  Map<String, dynamic> toJson() => null;

  @override
  String get id => null;
}

/// Deletion parameters of [RemoteMutationDataSource]'s [delete]
abstract class DeletionParams<T extends EquatableEntity> extends Equatable {}

/// Use this class if you don't need to add anything to the [DeletionParams]
class NoDeletionParams<T extends EquatableEntity> extends DeletionParams<T> {
  @override
  List<Object> get props => [];
}
