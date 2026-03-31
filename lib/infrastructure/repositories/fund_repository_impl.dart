import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/infrastructure/adapters/fund_adapter.dart';
import 'package:btg_funds_app/infrastructure/datasources/mock_api_datasource.dart';

class FundRepositoryImpl implements FundRepository {
  final MockApiDatasource _apiDatasource;
  final FundAdapter _fundAdapter;

  FundRepositoryImpl(this._apiDatasource, this._fundAdapter);

  @override
  Future<List<Fund>> getAll() async {
    final dtos = await _apiDatasource.getFunds();
    return _fundAdapter.toListModel(dtos);
  }

  @override
  Future<Fund?> getById(String id) async {
    final dto = await _apiDatasource.getFundById(id);
    if (dto == null) return null;
    return _fundAdapter.toModel(dto);
  }
}
