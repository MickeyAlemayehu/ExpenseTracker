/// Abstract base for domain-level failures shown to the user.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}
