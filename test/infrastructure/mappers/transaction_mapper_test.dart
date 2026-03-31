import 'package:flutter_test/flutter_test.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/core/enums/transaction_type.dart';
import 'package:btg_funds_app/domain/models/transaction.dart';
import 'package:btg_funds_app/infrastructure/dtos/transaction_dto.dart';
import 'package:btg_funds_app/infrastructure/mappers/transaction_mapper.dart';

void main() {
  group('TransactionMapper', () {
    final testDate = DateTime(2025, 6, 15, 10, 30);

    test('toModel convierte DTO de suscripción correctamente', () {
      final dto = TransactionDto(
        id: 'tx-001',
        type: 'subscription',
        fundId: '1',
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
        amount: 75000,
        date: testDate,
        notificationMethod: 'email',
      );

      final model = TransactionMapper.toModel(dto);

      expect(model.id, 'tx-001');
      expect(model.type, TransactionType.subscription);
      expect(model.fundId, '1');
      expect(model.fundName, 'FPV_BTG_PACTUAL_RECAUDADORA');
      expect(model.amount, 75000);
      expect(model.date, testDate);
      expect(model.notificationMethod, NotificationMethod.email);
    });

    test('toModel convierte DTO de cancelación (sin notificación)', () {
      final dto = TransactionDto(
        id: 'tx-002',
        type: 'cancellation',
        fundId: '1',
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
        amount: 0,
        date: testDate,
      );

      final model = TransactionMapper.toModel(dto);

      expect(model.type, TransactionType.cancellation);
      expect(model.notificationMethod, isNull);
    });

    test('toDto convierte modelo correctamente', () {
      final model = FundTransaction(
        id: 'tx-003',
        type: TransactionType.subscription,
        fundId: '2',
        fundName: 'FPV_BTG_PACTUAL_ECOPETROL',
        amount: 125000,
        date: testDate,
        notificationMethod: NotificationMethod.sms,
      );

      final dto = TransactionMapper.toDto(model);

      expect(dto.id, 'tx-003');
      expect(dto.type, 'subscription');
      expect(dto.fundId, '2');
      expect(dto.amount, 125000);
      expect(dto.notificationMethod, 'sms');
    });

    test('conversión bidireccional mantiene datos intactos', () {
      final original = FundTransaction(
        id: 'tx-004',
        type: TransactionType.subscription,
        fundId: '3',
        fundName: 'DEUDAPRIVADA',
        amount: 50000,
        date: testDate,
        notificationMethod: NotificationMethod.email,
      );

      final dto = TransactionMapper.toDto(original);
      final restored = TransactionMapper.toModel(dto);

      expect(restored, original);
    });
  });
}
