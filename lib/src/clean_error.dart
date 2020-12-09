import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// A common exception for your dependencies exceptions so our repository
/// can automatically converts it into a [CleanFailure].
///
/// The complete docs is written in the [CleanFailure], because [CleanException]
/// should not used extensively other than to convert various exception into one
/// common type.
class CleanException extends Equatable implements Exception {
  /// The error name. Suggested format is capitalized snake case.
  /// e.g. AUTHENTICATION_ERROR.
  ///
  /// A required field.
  final String name;

  /// Error group. This field is used to better assign exception to the user.
  /// For example, if the [name] is INSUFFICIENT_LENGTH,
  /// and [group] is PASSWORD, you can easily show the error under the password
  /// text field.
  final String group;

  /// Multipurpose field to store exception data. Use this in the case the
  /// error is unexpected, and just put it in log file or something.
  final Map<String, dynamic> data;

  const CleanException({@required this.name, this.group, this.data});

  @override
  List<Object> get props => [name, group, data];
}

/// The "safe" version of an exception. The conversion from exception to this
/// usually done in the repository.
///
/// I don't recommend putting error message in this. Because the non-UI layer
/// doesn't really care on how you present your error message, nor the language
/// you presented it in.
///
/// Instead, use a translation library to display your error message on the UI
/// layer with, for example, [FlutterI18n](https://pub.dev/packages/flutter_i18n).
///
/// Example:
/// ```
/// /// The object
/// final failure1 = CleanFailure(
///   name: 'INSUFFICIENT_LENGTH',
///   group: 'PASSWORD'
/// );
///
/// /// error.yaml
/// PASSWORD:
///   INSUFFICIENT_LENGTH: 'Your error message of your language of choice'
///
/// /// The object
/// final failure2 = CleanFailure(name: 'AUTH_ERROR');
///
/// /// error.yaml
/// AUTH_ERROR: 'Your error message of your language of choice'
/// ```
class CleanFailure extends Equatable {
  /// The error name. Suggested format is capitalized snake case
  /// e.g. AUTHENTICATION_ERROR.
  final String name;

  /// Error group. This field is used to better assign failure message
  /// to the user. For example, if the [name] is INSUFFICIENT_LENGTH,
  /// and [group] is PASSWORD, you can easily show the error under the password
  /// text field.
  final String group;

  /// Multipurpose field to store failure data. Use this in the case the
  /// error is unexpected, and just put it in log file or something.
  final Map<String, dynamic> data;

  const CleanFailure({@required this.name, this.group, this.data});

  /// Returns the formatted failure code to make it easier to map to
  /// your favorite translation library.
  ///
  /// e.g.
  /// 1. name = 'TEST_ERROR' and group = 'PASSWORD'
  /// Result = error.PASSWORD.TEST_ERROR
  ///
  /// 2. name = 'TEST_OTHER_ERROR'
  /// Result = error.TEST_OTHER_ERROR
  String get code {
    if (group == null || group.isEmpty) {
      return 'error.$name';
    }

    return 'error.$group.$name';
  }

  @override
  List<Object> get props => [name, group, data];
}
