/// Tamanhos de letra que o fiel pode escolher.
/// Para criar ou ajustar um tamanho, edite apenas esta lista.
enum TamanhoLetra {
  normal(1.0, 'Normal'),
  grande(1.3, 'Grande'),
  extraGrande(1.6, 'Extra grande');

  const TamanhoLetra(this.fator, this.rotulo);

  /// Multiplicador aplicado a todos os textos do app.
  final double fator;

  /// Nome mostrado na tela.
  final String rotulo;
}
