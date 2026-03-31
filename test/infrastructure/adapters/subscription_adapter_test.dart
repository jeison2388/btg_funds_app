import 'package:flutter_test/flutter_test.dart';
import 'package:btg_funds_app/core/enums/notification_method.dart';
import 'package:btg_funds_app/domain/models/subscription.dart';
import 'package:btg_funds_app/infrastructure/adapters/subscription_adapter.dart';
import 'package:btg_funds_app/infrastructure/dtos/subscription_dto.dart';

void main() {
  group('SubscriptionAdapter', () {
    const adapter = SubscriptionAdapter();
    final testDate = DateTime(2025, 6, 15, 10, 30);

    test('toModel convierte DTO a modelo correctamente', () {
      final dto = SubscriptionDto(
        fundId: '1',
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
        amount: 75000,
        date: testDate,
        notificationMethod: 'email',
      );

      final model = adapter.toModel(dto);

      expect(model.fundId, '1');
      expect(model.fundName, 'FPV_BTG_PACTUAL_RECAUDADORA');
      expect(model.amount, 75000);
      expect(model.date, testDate);
      expect(model.notificationMethod, NotificationMethod.email);
    });

    test('fromModel convierte modelo a DTO correctamente', () {
      final model = Subscription(
        fundId: '2',
        fundName: 'FPV_BTG_PACTUAL_ECOPETROL',
        amount: 125000,
        date: testDate,
        notificationMethod: NotificationMethod.sms,
      );

      final dto = adapter.fromModel(model);

      expect(dto.fundId, '2');
      expect(dto.fundName, 'FPV_BTG_PACTUAL_ECOPETROL');
      expect(dto.amount, 125000);
      expect(dto.date, testDate);
      expect(dto.notificationMethod, 'sms');
    });

    test('conversión bidireccional mantiene datos intactos', () {
      final original = Subscription(
        fundId: '3',
        fundName: 'DEUDAPRIVADA',
        amount: 50000,
        date: testDate,
        notificationMethod: NotificationMethod.email,
      );

      final dto = adapter.fromModel(original);
      final restored = adapter.toModel(dto);

      expect(restored, original);
    });
  });
}
