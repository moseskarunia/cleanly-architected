import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:equatable/equatable.dart';

/// Query parameters of [RemoteQueryDataSource]'s [read].
abstract class QueryParams<T> extends Equatable {
  const QueryParams();
}

/// Use this class if you don't need to add anything to the [QueryParams]
class NoQueryParams<T> extends QueryParams<T> {
  const NoQueryParams();
  @override
  List<Object> get props => [];
}

/// Mutation parameters of [RemoteMutationDataSource]'s [create] and [update].
abstract class MutationParams<T> extends Equatable {}

/// Use this class if you don't need to add anything to the [MutationParams]
class NoMutationParams<T> extends MutationParams<T> {
  @override
  List<Object> get props => [];
}

/// Deletion parameters of [RemoteMutationDataSource]'s [delete]
abstract class DeletionParams<T> extends Equatable {}

/// Use this class if you don't need to add anything to the [DeletionParams]
class NoDeletionParams<T> extends DeletionParams<T> {
  @override
  List<Object> get props => [];
}
