
import 'dart:convert';

class Trabajador {
  int? idtrabajador;
  String? codcliente;
  int? idcentro;
  int? idcargo;
  String? nombre;
  String? dni;
  String? telefono;
  String? email;
  Trabajador({
    this.idtrabajador,
    this.codcliente,
    this.idcentro,
    this.idcargo,
    this.nombre,
    this.dni,
    this.telefono,
    this.email,
  });


  Trabajador copyWith({
    int? idtrabajador,
    String? codcliente,
    int? idcentro,
    int? idcargo,
    String? nombre,
    String? dni,
    String? telefono,
    String? email,
  }) {
    return Trabajador(
      idtrabajador: idtrabajador ?? this.idtrabajador,
      codcliente: codcliente ?? this.codcliente,
      idcentro: idcentro ?? this.idcentro,
      idcargo: idcargo ?? this.idcargo,
      nombre: nombre ?? this.nombre,
      dni: dni ?? this.dni,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idtrabajador': idtrabajador,
      'codcliente': codcliente,
      'idcentro': idcentro,
      'idcargo': idcargo,
      'nombre': nombre,
      'dni': dni,
      'telefono': telefono,
      'email': email,
    };
  }

  factory Trabajador.fromMap(Map<String, dynamic> map) {
    return Trabajador(
      idtrabajador: map['idtrabajador'] != null ? map['idtrabajador'] as int : null,
      codcliente: map['codcliente'] != null ? map['codcliente'] as String : null,
      idcentro: map['idcentro'] != null ? map['idcentro'] as int : null,
      idcargo: map['idcargo'] != null ? map['idcargo'] as int : null,
      nombre: map['nombre'] != null ? map['nombre'] as String : null,
      dni: map['dni'] != null ? map['dni'] as String : null,
      telefono: map['telefono'] != null ? map['telefono'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Trabajador.fromJson(String source) => Trabajador.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Trabajador(idtrabajador: $idtrabajador, codcliente: $codcliente, idcentro: $idcentro, idcargo: $idcargo, nombre: $nombre, dni: $dni, telefono: $telefono, email: $email)';
  }

  @override
  bool operator ==(covariant Trabajador other) {
    if (identical(this, other)) return true;
  
    return 
      other.idtrabajador == idtrabajador &&
      other.codcliente == codcliente &&
      other.idcentro == idcentro &&
      other.idcargo == idcargo &&
      other.nombre == nombre &&
      other.dni == dni &&
      other.telefono == telefono &&
      other.email == email;
  }

  @override
  int get hashCode {
    return idtrabajador.hashCode ^
      codcliente.hashCode ^
      idcentro.hashCode ^
      idcargo.hashCode ^
      nombre.hashCode ^
      dni.hashCode ^
      telefono.hashCode ^
      email.hashCode;
  }
}
