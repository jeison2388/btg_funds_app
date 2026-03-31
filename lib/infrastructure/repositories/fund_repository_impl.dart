import 'package:btg_funds_app/domain/models/fund.dart';
import 'package:btg_funds_app/domain/repositories/fund_repository.dart';
import 'package:btg_funds_app/infrastructure/datasources/mock_api_datasource.dart';

class FundRepositoryImpl implements FundRepository {
  final MockApiDatasource _apiDatasource;

  FundRepositoryImpl(this._apiDatasource);

  @override
  Future<List<Fund>> getAll() => _apiDatasource.getFunds();

  @override
  Future<Fund?> getById(String id) => _apiDatasource.getFundById(id);
}
