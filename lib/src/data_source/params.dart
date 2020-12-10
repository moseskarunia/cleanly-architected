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
  const MutationParams();

  /// Will be used as values for in [LocalMutationDataSource]'s putAll.
  /// The key should be field name, and the value is the value of cached form
  /// value.
  ///
  /// For example if there are 2 fields, name and address, the return should be:
  /// ```
  /// {
  ///   'name': 'John Doe',
  ///   'address': 'Sesame Street 18'
  /// }
  /// ```
  Map<String, dynamic> toJson();
}

/// Use this class if you don't need to add anything to the [MutationParams]
class NoMutationParams<T extends EquatableEntity> extends MutationParams<T> {
  @override
  List<Object> get props => [];

  @override
  Map<String, dynamic> toJson() => null;
}

/// Deletion parameters of [RemoteMutationDataSource]'s [delete]
abstract class DeletionParams<T extends EquatableEntity> extends Equatable {}

/// Use this class if you don't need to add anything to the [DeletionParams]
class NoDeletionParams<T extends EquatableEntity> extends DeletionParams<T> {
  @override
  List<Object> get props => [];
}
