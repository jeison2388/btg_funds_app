import 'package:btg_funds_app/core/constants/app_constants.dart';
import 'package:btg_funds_app/domain/models/fund.dart';

/// Simula una API REST con delays artificiales para demostrar loading states.
class MockApiDatasource {
  static const _simulatedDelay = Duration(milliseconds: 500);

  Future<List<Fund>> getFunds() async {
    await Future.delayed(_simulatedDelay);
    return AppConstants.availableFunds;
  }

  Future<Fund?> getFundById(String id) async {
    await Future.delayed(_simulatedDelay);
    try {
      return AppConstants.availableFunds.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
