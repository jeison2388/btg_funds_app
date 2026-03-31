enum TransactionType {
  subscription('Suscripción'),
  cancellation('Cancelación');

  final String label;
  const TransactionType(this.label);
}
