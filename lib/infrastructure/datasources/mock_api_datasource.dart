import 'package:btg_funds_app/infrastructure/dtos/fund_dto.dart';

/// Simula una API REST: solo entra y sale [FundDto] (como JSON deserializado).
class MockApiDatasource {
  static const _simulatedDelay = Duration(milliseconds: 500);

  /// Respuesta simulada de catálogo (equivalente a GET /funds).
  static const List<FundDto> _catalog = [
    FundDto(
      id: '1',
      name: 'FPV_BTG_PACTUAL_RECAUDADORA',
      minimumAmount: 75000,
      category: 'fpv',
    ),
    FundDto(
      id: '2',
      name: 'FPV_BTG_PACTUAL_ECOPETROL',
      minimumAmount: 125000,
      category: 'fpv',
    ),
    FundDto(
      id: '3',
      name: 'DEUDAPRIVADA',
      minimumAmount: 50000,
      category: 'fic',
    ),
    FundDto(
      id: '4',
      name: 'FDO-ACCIONES',
      minimumAmount: 250000,
      category: 'fic',
    ),
    FundDto(
      id: '5',
      name: 'FPV_BTG_PACTUAL_DINAMICA',
      minimumAmount: 100000,
      category: 'fpv',
    ),
  ];

  Future<List<FundDto>> getFunds() async {
    await Future.delayed(_simulatedDelay);
    return List<FundDto>.from(_catalog);
  }

  Future<FundDto?> getFundById(String id) async {
    await Future.delayed(_simulatedDelay);
    try {
      return _catalog.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
