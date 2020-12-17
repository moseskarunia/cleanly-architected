## [0.0.4] - 17 December 2020
- (BREAKING!) `EquatableEntity` no longer requires id, instead, it now requires you to override a getter called `entityIdentifier`. This is the new way to get unique field from your entity. This way, you can have your own `id`. I named it `entityIdentifier` for less chance to conflict with your own field name. _(Copied from cleanly_architected_core 0.0.8 changelog)_

## [0.0.3] - 14 December 2020
- Make readme file better

## [0.0.2] - 14 December 2020

- No longer depends on build_runner and copy_with.
- Improve docs.

## [0.0.1] - 13 December 2020

- Create `CreateFormCubit`, `UpdateFormCubit`, `QueryCubit`, and `DeletionCubit`