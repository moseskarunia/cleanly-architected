# cleanly_architected

![cleanly_architected_master_ci](https://github.com/moseskarunia/cleanly-architected/workflows/cleanly_architected_master_ci/badge.svg?branch=master) [![codecov](https://codecov.io/gh/moseskarunia/cleanly-architected/branch/master/graph/badge.svg?token=3AT2NUV710)](https://codecov.io/gh/moseskarunia/cleanly-architected)

A flutter library to help you lay down the foundation of clean architecture without having to a lot to set up initially. This library heavily utilizes generics to achieve this.

Everyone agrees architecture is good, but it considerably slows the development initiation process. Multiply it by implementing the foundation each time you want to start a project, then new projects won't spark joy anymore. Unfortunately, we can't ditch it even though it doesn't spark joy (sorry Marie Kondo), because a maintainable app needs to be architected cleanly.

## Planned Updates
- Form caching in Mutation Repository: Make it easier for you to save form state, to enable user to continue editing later.

Feel free to submit PR for them. The functions already available in the data source though, the repository just need to wire things up.

## What is Clean Architecture?

For you who is new to the architecture world, I highly advise you to follow through [Reso Coder's tutorial on TDD](https://resocoder.com/category/tutorials/flutter/tdd-clean-architecture/). This library is my iteration on that tutorial. And I think you need to understand it first before trying to use this library.

Basically, clean architecture separates the app into several layers, which is independent of each others.
- Entity: Equivalent to POJO. But this time, it's PODO (Plain Old Dart Object).
- Data Source: Layer to contact, (surprise) data sources, both local and remote. Remote data sources contacts your server through its API, interfaced through `CleanApiClient`. Local data sources store obtained remote data locally.
- Repository: It acts as the hub of local and remote data source, cache the data (to prevent repeatedly contacting the data source) and also the layer to handle exceptions, converts it into Failure, and return it with dartz union type. This way, our app will be more robust and easier to manage by handling exceptions as early as possible.
- Interactor: Holds logics such as validations. An interactor can depends on other interactor.
- State Manager: I personally use bloc. But for the sake of liberty, I'll put the state management library separately.

## In depth explanation of each layers

_Under construction_