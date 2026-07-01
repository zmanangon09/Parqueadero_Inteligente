enum EstadoEspacio { libre, ocupado, reservado }

enum TipoEspacio { normal, discapacitado, electrico }

class EspacioEntity {
  final String id;
  final String parqueaderoId;
  final int numero;
  final EstadoEspacio estado;
  final TipoEspacio tipo;

  const EspacioEntity({
    required this.id,
    required this.parqueaderoId,
    required this.numero,
    required this.estado,
    required this.tipo,
  });

  bool get isLibre => estado == EstadoEspacio.libre;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EspacioEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
