// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:btg_funds_app/domain/models/fund.dart' as _i7;
import 'package:btg_funds_app/presentation/screens/funds_screen.dart' as _i1;
import 'package:btg_funds_app/presentation/screens/home_screen.dart' as _i2;
import 'package:btg_funds_app/presentation/screens/subscribe_screen.dart'
    as _i3;
import 'package:btg_funds_app/presentation/screens/transaction_history_screen.dart'
    as _i4;
import 'package:flutter/material.dart' as _i6;

/// generated route for
/// [_i1.FundsScreen]
class FundsRoute extends _i5.PageRouteInfo<void> {
  const FundsRoute({List<_i5.PageRouteInfo>? children})
      : super(FundsRoute.name, initialChildren: children);

  static const String name = 'FundsRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.FundsScreen();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i5.PageRouteInfo<void> {
  const HomeRoute({List<_i5.PageRouteInfo>? children})
      : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i2.PortfolioScreen]
class PortfolioRoute extends _i5.PageRouteInfo<void> {
  const PortfolioRoute({List<_i5.PageRouteInfo>? children})
      : super(PortfolioRoute.name, initialChildren: children);

  static const String name = 'PortfolioRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.PortfolioScreen();
    },
  );
}

/// generated route for
/// [_i3.SubscribeScreen]
class SubscribeRoute extends _i5.PageRouteInfo<SubscribeRouteArgs> {
  SubscribeRoute({
    _i6.Key? key,
    required _i7.Fund fund,
    List<_i5.PageRouteInfo>? children,
  }) : super(
          SubscribeRoute.name,
          args: SubscribeRouteArgs(key: key, fund: fund),
          initialChildren: children,
        );

  static const String name = 'SubscribeRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SubscribeRouteArgs>();
      return _i3.SubscribeScreen(key: args.key, fund: args.fund);
    },
  );
}

class SubscribeRouteArgs {
  const SubscribeRouteArgs({this.key, required this.fund});

  final _i6.Key? key;

  final _i7.Fund fund;

  @override
  String toString() {
    return 'SubscribeRouteArgs{key: $key, fund: $fund}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SubscribeRouteArgs) return false;
    return key == other.key && fund == other.fund;
  }

  @override
  int get hashCode => key.hashCode ^ fund.hashCode;
}

/// generated route for
/// [_i4.TransactionHistoryScreen]
class TransactionHistoryRoute extends _i5.PageRouteInfo<void> {
  const TransactionHistoryRoute({List<_i5.PageRouteInfo>? children})
      : super(TransactionHistoryRoute.name, initialChildren: children);

  static const String name = 'TransactionHistoryRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i4.TransactionHistoryScreen();
    },
  );
}
