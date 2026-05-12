import 'dart:convert';

class Tiposolicitud {
  int? idtiposolicitud;
  String? nombre;
  Tiposolicitud({
    this.idtiposolicitud,
    this.nombre,
  });

  Tiposolicitud copyWith({
    int? idtiposolicitud,
    String? nombre,
  }) {
    return Tiposolicitud(
      idtiposolicitud: idtiposolicitud ?? this.idtiposolicitud,
      nombre: nombre ?? this.nombre,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idtiposolicitud': idtiposolicitud,
      'nombre': nombre,
    };
  }

  factory Tiposolicitud.fromMap(Map<String, dynamic> map) {
    return Tiposolicitud(
      idtiposolicitud: map['idtiposolicitud'] != null ? map['idtiposolicitud'] as int : null,
      nombre: map['nombre'] != null ? map['nombre'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tiposolicitud.fromJson(String source) => Tiposolicitud.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Tiposolicitud(idtiposolicitud: $idtiposolicitud, nombre: $nombre)';

  @override
  bool operator ==(covariant Tiposolicitud other) {
    if (identical(this, other)) return true;
  
    return 
      other.idtiposolicitud == idtiposolicitud &&
      other.nombre == nombre;
  }

  @override
  int get hashCode => idtiposolicitud.hashCode ^ nombre.hashCode;
}
