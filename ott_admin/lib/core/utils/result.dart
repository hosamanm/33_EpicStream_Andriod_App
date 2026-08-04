import '../error/failures.dart';

/// A generic class that holds a value or a failure.
/// Used to handle operations that can fail in a predictable way.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(Failure failure) = ErrorResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isError => this is ErrorResult<T>;

  T get data => (this as Success<T>).value;
  Failure get failure => (this as ErrorResult<T>).error;

  /// Transformation utility to handle both cases in a functional style.
  R fold<R>(
    R Function(Failure failure) onError,
    R Function(T data) onSuccess,
  ) {
    if (this is Success<T>) {
      return onSuccess((this as Success<T>).value);
    } else {
      return onError((this as ErrorResult<T>).error);
    }
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class ErrorResult<T> extends Result<T> {
  final Failure error;
  const ErrorResult(this.error);
}
