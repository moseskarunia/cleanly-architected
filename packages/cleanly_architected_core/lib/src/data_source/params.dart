import 'package:cleanly_architected_core/src/data_source/local_data_source.dart';
import 'package:cleanly_architected_core/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected_core/src/entity/equatable_entity.dart';
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
abstract class FormParams<T extends EquatableEntity> extends Equatable {
  const FormParams();

  /// Will be used as values for in [LocalFormCacheDataSource]'s putAll.
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

/// Use this class if you don't need to add anything to the [FormParams]
class NoFormParams<T extends EquatableEntity> extends FormParams<T> {
  @override
  List<Object> get props => [];

  @override
  Map<String, dynamic> toJson() => null;
}
