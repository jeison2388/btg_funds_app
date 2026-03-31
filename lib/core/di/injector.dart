import 'package:kiwi/kiwi.dart';
import 'package:btg_funds_app/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/domain/repositories/portfolio_repository.dart';
import 'package:btg_funds_app/domain/repositories/transaction_repository.dart';
import 'package:btg_funds_app/infrastructure/datasources/hive_local_datasource.dart';
import 'package:btg_funds_app/infrastructure/datasources/mock_api_datasource.dart';
import 'package:btg_funds_app/infrastructure/repositories/fund_repository_impl.dart';
import 'package:btg_funds_app/infrastructure/repositories/portfolio_repository_impl.dart';
import 'package:btg_funds_app/infrastructure/repositories/transaction_repository_impl.dart';
import 'package:btg_funds_app/presentation/cubits/funds/funds_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/portfolio/portfolio_cubit.dart';
import 'package:btg_funds_app/presentation/cubits/transactions/transactions_cubit.dart';

abstract class Injector {
  static final KiwiContainer container = KiwiContainer();

  static void setup() {
    // Datasources
    container.registerSingleton((_) => MockApiDatasource());
    container.registerSingleton((_) => HiveLocalDatasource());

    // Repositories
    container.registerFactory<FundRepository>(
      (c) => FundRepositoryImpl(c.resolve<MockApiDatasource>()),
    );
    container.registerFactory<PortfolioRepository>(
      (c) => PortfolioRepositoryImpl(c.resolve<HiveLocalDatasource>()),
    );
    container.registerFactory<TransactionRepository>(
      (c) => TransactionRepositoryImpl(c.resolve<HiveLocalDatasource>()),
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
