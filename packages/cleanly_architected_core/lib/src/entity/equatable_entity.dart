import 'package:equatable/equatable.dart';

/// Entity with equatable which also implements id.
/// The goals of this is to make it easier for some layer to extract id,
/// like to remove duplication in repository, and getting key in local data
/// source.
abstract class EquatableEntity extends Equatable {
  /// Id must be string. This to simplify the case to store the entity locally
  /// with key-value database.
  final String id;

  const EquatableEntity(this.id);

  /// Will be used in [LocalQueryDataSource]'s putAll.
  /// So you don't have to keep implementing the same things multiple times.
  Map<String, dynamic> toJson();
}
