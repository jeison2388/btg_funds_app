import 'package:btg_funds_app/domain/models/fund.dart';

abstract class FundRepository {
  Future<List<Fund>> getAll();
  Future<Fund?> getById(String id);
}
