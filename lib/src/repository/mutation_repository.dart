import 'package:cleanly_architected/src/data_source/local_data_source.dart';
import 'package:cleanly_architected/src/data_source/params.dart';
import 'package:cleanly_architected/src/data_source/remote_data_source.dart';
import 'package:cleanly_architected/src/entity/equatable_entity.dart';
import 'package:meta/meta.dart';

/// The repository of mutation. This class manages form caching, for example
/// in a case when you need to store state of a form to be edited again later.
///
/// In a more specific case, you can always make a class, extends this,
/// and override its properties. Otherwise, you just need to register it
/// to your service locator (such as [GetIt](https://pub.dev/packages/get_it))
/// with different T.
class MutationRepository<T extends EquatableEntity, U extends MutationParams<T>,
    V extends DeletionParams<T>> {
  final RemoteMutationDataSource<T, U, V> remoteMutationDataSource;
  final LocalMutationDataSource<T, U> localDataSource;

  @visibleForTesting
  U lastMutationParams;

  MutationRepository({
    this.remoteMutationDataSource,
    this.localDataSource,
  });
}
