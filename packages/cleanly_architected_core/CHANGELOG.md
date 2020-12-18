## [0.0.11] - 18 December 2020
Removed both `GraphQLParams` and `CleanApiClient`. After further consideration. I think this put unecessary restriction on the implementation without much to gain. I will still keep `CleanLocalStorage`, because it will make some functions in `LocalFormCacheDataSource` and `LocalDataSource` doesn't need to be keep re-implemented each time.

If you still need `GraphQLParams` in your project, feel free to copy it to your own personal project (along with its test file).

## [0.0.10] - 18 December 2020
- Forgot to add `GraphQLParams` to barrel export.

_Copied from 0.0.9_
- (BREAKING!) `CleanApiClient` to better match HTTP request names: read -> get, create -> post, update -> put
- Support GraphQL parameters in `CleanApiClient` post.

## [0.0.9] - 18 December 2020
- (BREAKING!) `CleanApiClient` to better match HTTP request names: read -> get, create -> post, update -> put
- Support GraphQL parameters in `CleanApiClient` post.

## [0.0.8] - 17 December 2020
- Sorry! I released too hasty (0.0.7) and confidently without PR and waiting CI to complete.
- Fix ci failed caused by dartfmt.
- (BREAKING!) `EquatableEntity` no longer requires id, instead, it now requires you to override a getter called `entityIdentifier`. This is the new way to get unique field from your entity. This way, you can have your own `id`. I named it `entityIdentifier` for less chance to conflict with your own field name.

## [0.0.7] - 17 December 2020
- (BREAKING!) `EquatableEntity` no longer requires id, instead, it now requires you to override a getter called `entityIdentifier`. This is the new way to get unique field from your entity. This way, you can have your own `id`. I named it `entityIdentifier` for less chance to conflict with your own field name.

## [0.0.6] - 14 December 2020
- Make readme file better

## [0.0.5] - 12 December 2020
- Removes flutter dependency
- Untrack pubspec.lock

## [0.0.4] - 12 December 2020
- Rework architecture.
- Interactor / Use case or `Create`, `Update` and `Delete` will automatically reflects the change to `DataRepository` as well.
- [TODO]: Empty form_cache_repository to be made later.

## [0.0.3] - 11 December 2020
- Add coverage badge to README.
- Format some document to pass pub.dev static analysis.

## [0.0.2] - 11 December 2020
Added Changelog file.

## [0.0.1] - 11 December 2020
1. Query Repository: 
  * Exception handling -> CleanFailure
  * Support pagination which specialized for infinite-scrolling list
  * Connecting remote data source call and local data source call for caching
2. Mutation Repository:
  * Exception handling -> CleanFailure
  * Support create, update, and delete to remote data source
  * Connecting remote data source call and updating locally-cached data afterward

and many more.