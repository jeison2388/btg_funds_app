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
            AutoRoute(page: PortfolioRoute.page),
            AutoRoute(page: FundsRoute.page),
            AutoRoute(page: TransactionHistoryRoute.page),
          ],
        ),
        CustomRoute(
          page: SubscribeRoute.page,
          fullscreenDialog: true,
          transitionsBuilder: TransitionsBuilders.slideBottom,
          guards: [_SubscribeGuard()],
        ),
      ];
}

/// Protege la ruta de suscripción contra accesos sin argumentos
/// (p. ej. botón atrás del navegador web que reconstruye la URL).
class _SubscribeGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final route = resolver.route;
    if (route.args is SubscribeRouteArgs) {
      resolver.next();
    } else {
      router.replaceAll([const HomeRoute()]);
    }
  }
}
