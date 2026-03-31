import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:btg_funds_app/core/di/injector.dart';
import 'package:btg_funds_app/core/routes/app_router.dart';
import 'package:btg_funds_app/core/theme/app_theme.dart';
import 'package:btg_funds_app/infrastructure/datasources/hive_local_datasource.dart';
import 'package:btg_funds_app/infrastructure/dtos/subscription_dto.dart';
import 'package:btg_funds_app/infrastructure/dtos/transaction_dto.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'es';
  await initializeDateFormatting('es');

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(SubscriptionDtoAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TransactionDtoAdapter());
  }

  Injector.setup();

  final localDatasource = Injector.resolve<HiveLocalDatasource>();
  await localDatasource.init();

  runApp(const BtgFundsApp());
}

class BtgFundsApp extends StatelessWidget {
  const BtgFundsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      title: 'BTG Funds',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter.config(),
    );
  }
}
