import 'package:kiwi/kiwi.dart';
import 'package:btg_funds_app/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/domain/repositories/portfolio_repository.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/infrastructure/adapters/fund_adapter.dart';
import 'package:btg_funds_app/infrastructure/adapters/subscription_adapter.dart';
import 'package:btg_funds_app/infrastructure/adapters/transaction_adapter.dart';
import 'package:btg_funds_app/infrastructure/datasources/hive_local_datasource.dart';
import 'package:btg_funds_app/infrastructure/datasources/mock_api_datasource.dart';
import 'package:btg_funds_app/infrastructure/repositories/fund_repository_impl.dart';
import 'package:btg_funds_app/infrastructure/repositories/portfolio_repository_impl.dart';
import 'package:btg_funds_app/infrastructure/repositories/transaction_repository_impl.dart';
import 'package:btg_funds_app/presentation/funds/funds_cubit.dart';
import 'package:btg_funds_app/presentation/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/transaction_history/transactions_cubit.dart';

abstract class Injector {
  static final KiwiContainer container = KiwiContainer();

  static void setup() {
    // Adapters (contrato dominio ↔ DTO / persistencia)
    container.registerSingleton((_) => const FundAdapter());
    container.registerSingleton((_) => const SubscriptionAdapter());
    container.registerSingleton((_) => const TransactionAdapter());

    // Datasources
    container.registerSingleton((_) => MockApiDatasource());
    container.registerSingleton((_) => HiveLocalDatasource());

    // Repositories
    container.registerFactory<FundRepository>(
      (c) => FundRepositoryImpl(
        c.resolve<MockApiDatasource>(),
        c.resolve<FundAdapter>(),
      ),
    );
    container.registerFactory<PortfolioRepository>(
      (c) => PortfolioRepositoryImpl(
        c.resolve<HiveLocalDatasource>(),
        c.resolve<SubscriptionAdapter>(),
      ),
    );
    container.registerFactory<TransactionRepository>(
      (c) => TransactionRepositoryImpl(
        c.resolve<HiveLocalDatasource>(),
        c.resolve<TransactionAdapter>(),
      ),
    );

    // Cubits
    container.registerFactory(
      (c) => FundsCubit(c.resolve<FundRepository>()),
    );
    container.registerFactory(
      (c) => PortfolioCubit(
        c.resolve<PortfolioRepository>(),
        c.resolve<TransactionRepository>(),
      ),
    );
    container.registerFactory(
      (c) => TransactionsCubit(c.resolve<TransactionRepository>()),
    );
  }

  static T resolve<T>() => container.resolve<T>();
}
