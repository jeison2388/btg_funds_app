class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

class InsufficientBalanceException extends AppException {
  const InsufficientBalanceException()
      : super('No tiene saldo suficiente para vincularse al fondo');
}

class AlreadySubscribedException extends AppException {
  const AlreadySubscribedException()
      : super('Ya se encuentra vinculado a este fondo');
}

class SubscriptionNotFoundException extends AppException {
  const SubscriptionNotFoundException()
      : super('No se encontró la vinculación al fondo');
}
