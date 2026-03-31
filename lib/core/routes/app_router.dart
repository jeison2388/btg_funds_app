import 'package:auto_route/auto_route.dart';
import 'package:btg_funds_app/core/routes/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeRoute.page,
          initial: true,
          children: [
            AutoRoute(page: FundsRoute.page),
            AutoRoute(page: PortfolioRoute.page),
            AutoRoute(page: TransactionHistoryRoute.page),
          ],
        ),
        AutoRoute(page: SubscribeRoute.page),
      ];
}
