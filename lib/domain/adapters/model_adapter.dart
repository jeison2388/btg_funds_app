/// Contrato para traducir entre modelos de dominio y representaciones externas
/// (DTOs, entidades de persistencia, respuestas de API, etc.).
abstract class ModelAdapter<Model, External> {
  const ModelAdapter();

  Model toModel(External external);

  External fromModel(Model model);

  List<Model> toListModel(List<External> external) {
    return external.map(toModel).toList();
  }

  List<External> fromListModel(List<Model> models) {
    return models.map(fromModel).toList();
  }
}
