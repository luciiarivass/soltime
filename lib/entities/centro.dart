import 'dart:convert';


class Centro {
  int? idcentro;
  String? codcliente;
  String? nombre;
  Centro({
    this.idcentro,
    this.codcliente,
    this.nombre,
  });

  Centro copyWith({
    int? idcentro,
    String? codcliente,
    String? nombre,
  }) {
    return Centro(
      idcentro: idcentro ?? this.idcentro,
      codcliente: codcliente ?? this.codcliente,
      nombre: nombre ?? this.nombre,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idcentro': idcentro,
      'codcliente': codcliente,
      'nombre': nombre,
    };
  }

  factory Centro.fromMap(Map<String, dynamic> map) {
    return Centro(
      idcentro: map['idcentro'] != null ? map['idcentro'] as int : null,
      codcliente: map['codcliente'] != null ? map['codcliente'] as String : null,
      nombre: map['nombre'] != null ? map['nombre'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Centro.fromJson(String source) => Centro.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Centro(idcentro: $idcentro, codcliente: $codcliente, nombre: $nombre)';

  @override
  bool operator ==(covariant Centro other) {
    if (identical(this, other)) return true;
  
    return 
      other.idcentro == idcentro &&
      other.codcliente == codcliente &&
      other.nombre == nombre;
  }

  @override
  int get hashCode => idcentro.hashCode ^ codcliente.hashCode ^ nombre.hashCode;
}
