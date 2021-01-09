## [0.0.10] - 9 January 2021

- Updated readme

## [0.0.9] - 28 December 2020
- Set minimum supported `cleanly_architected_core` to `0.0.13`. Read the changelog [here](https://github.com/moseskarunia/cleanly-architected/blob/master/packages/cleanly_architected_core/CHANGELOG.md)

## [0.0.8] - 28 December 2020
- Set minimum supported `cleanly_architected_core` to `0.0.12`. Read the changelog [here](https://github.com/moseskarunia/cleanly-architected/blob/master/packages/cleanly_architected_core/CHANGELOG.md)

## [0.0.7] - 18 December 2020
- Set minimum supported `cleanly_architected_core` to `0.0.11`. Read the changelog [here](https://github.com/moseskarunia/cleanly-architected/blob/master/packages/cleanly_architected_core/CHANGELOG.md)

## [0.0.6] - 18 December 2020
- Set minimum supported `cleanly_architected_core` to `0.0.10`. Read the changelog [here](https://github.com/moseskarunia/cleanly-architected/blob/master/packages/cleanly_architected_core/CHANGELOG.md)

## [0.0.5] - 18 December 2020
- Set minimum supported `cleanly_architected_core` to `0.0.9`. Read the changelog [here](https://github.com/moseskarunia/cleanly-architected/blob/master/packages/cleanly_architected_core/CHANGELOG.md)

## [0.0.4] - 17 December 2020
- (BREAKING!) `EquatableEntity` no longer requires id, instead, it now requires you to override a getter called `entityIdentifier`. This is the new way to get unique field from your entity. This way, you can have your own `id`. I named it `entityIdentifier` for less chance to conflict with your own field name. _(Copied from cleanly_architected_core 0.0.8 changelog)_

## [0.0.3] - 14 December 2020
- Make readme file better

## [0.0.2] - 14 December 2020

- No longer depends on build_runner and copy_with.
- Improve docs.

## [0.0.1] - 13 December 2020

- Create `CreateFormCubit`, `UpdateFormCubit`, `QueryCubit`, and `DeletionCubit`