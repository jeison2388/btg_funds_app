/// Representación de fondo tal como llegaría desde una API (JSON → parseo).
class FundDto {
  final String id;
  final String name;
  final double minimumAmount;

  /// Valores esperados: `fpv`, `fic` (coinciden con [FundCategory.name]).
  final String category;

  const FundDto({
    required this.id,
    required this.name,
    required this.minimumAmount,
    required this.category,
  });
}
