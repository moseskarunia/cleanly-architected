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