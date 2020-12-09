# cleanly_architected

A flutter library to help you lay down the foundation of clean architecture without having to a lot to set up initially. This library heavily utilizes generics to achieve this.

Everyone agrees architecture is good, but it considerably slows the development initiation process. Multiply it by implementing the foundation each time you want to start a project, then new projects won't spark joy anymore. Unfortunately, we can't ditch it even though it doesn't spark joy (sorry Marie Kondo), because a maintainable app needs to be architected cleanly.

## What is Clean Architecture?

For you who is new to the architecture world, I highly advise you to follow through [Reso Coder's tutorial on TDD](https://resocoder.com/category/tutorials/flutter/tdd-clean-architecture/). This library is my iteration on that tutorial. And I think you need to understand it first before trying to use this library.

Basically, clean architecture separates the app into several layers, which is independent of each others.
- Entity: Equivalent to POJO. But this time, it's PODO.
- Data Source: Layer to contact, surprise, data sources, both local and remote. Remote data sources contacts your server through its API, and local data sources store obtained remote data locally to improve app cold start and reduce user's data usage.
- Repository: It acts as the hub of local and remote data source, cache the data (to prevent repeatedly contacting the data source) and also the layer to handle exceptions, converts it into Failure, and return it with dartz union type. This way, our app will be more robust and easier to manage by handling exceptions as early as possible.
- Interactor: Holds logics such as validations. An interactor can depends on other interactor.
- State Manager: I personally use bloc. But for the sake of liberty, I'll put the state management library separately.

## In depth explanation of each layers

### 1. Entity
Equivalent to Plain Old Java Object or POJO, but this time, it's Plain Old Dart Object (PODO). It's highly advised for your entities to implement (Equatable)[https://pub.dev/packages/equatable] for easier object comparison.

### 2. Data Source
There are 2 kinds of data sources:

#### Remote Data Source
Its responsibility is contacting the server through an API to fetch / send some data. In this library, I give you an abstract class to extend. Why do you need to extend it? The purpose of it is to make it visible to the repository layer when combined with generic types.

In clean architecture, each layer should be independent to each other. This is the purpose of `CleanApiClient`. This makes it possible for you to swap out the default Flutter HttpClient to other 3rd party such as Dio in the future, without damaging your data source layer, as long as it also implements `CleanApiClient`.

```dart
abstract class CleanApiClient {
  List<Map<String,dynamic>> read({@required String path, Map<String,dynamic> queryParams});
  Map<String,dynamic> create({@required String path, Map<String,dynamic> body});
  Map<String,dynamic> update({@required String path, Map<String,dynamic> body});
  void delete({@required String path});
}
```

##### QueryDataSource 
The data source to extend if you need query functionalities. 

```dart
abstract class QueryDataSource<T extends Equatable, U extends QueryParams<T>> {
  final CleanApiClient client;

  const QueryDataSource({@required this.client});
  
  List<T> read(U params){
    /// Make some logic to call [client.read]
  }
}
```

If there are custom exception from any API you are using in the data source, you have to convert it into a `CleanException`. The purpose of this is to make our repository easily converts it into a `Failure`.

#### Local Data Source