import 'dart:convert';
import 'package:intl/intl.dart';

class Fichaje {
  int? idfichaje;
  int? idtrabajador;
  String? codcliente;
  int? idcentro;
  String? foto;
  String? geolocalizacion;
  DateTime? fecha_hora_entrada;
  DateTime? fecha_hora_salida;
  String? solicitud;

  Fichaje({
    this.idfichaje,
    this.idtrabajador,
    this.codcliente,
    this.idcentro,
    this.foto,
    this.geolocalizacion,
    this.fecha_hora_entrada,
    this.fecha_hora_salida,
    this.solicitud,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idfichaje': idfichaje,
      'idtrabajador': idtrabajador,
      'codcliente': codcliente,
      'idcentro': idcentro,
      'foto': foto,
      'geolocalizacion': geolocalizacion,
      'fecha_hora_entrada': fecha_hora_entrada?.millisecondsSinceEpoch,
      'fecha_hora_salida': fecha_hora_salida?.millisecondsSinceEpoch,
      'solicitud': solicitud,
    };
  }

  factory Fichaje.fromMap(Map<String, dynamic> map) {
    DateTime? parseFecha(dynamic value) {
      if (value == null) return null;

      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }

      if (value is String && value.isNotEmpty) {
        try {
          return DateFormat('dd-MM-yyyy HH:mm:ss').parse(value);
        } catch (_) {
          return null;
        }
      }

      return null;
    }

    return Fichaje(
      idfichaje: map['idfichaje'] is int
          ? map['idfichaje']
          : int.tryParse(map['idfichaje']?.toString() ?? ''),
      idtrabajador: map['idtrabajador'] is int
          ? map['idtrabajador']
          : int.tryParse(map['idtrabajador']?.toString() ?? ''),
      codcliente: map['codcliente']?.toString(),
      idcentro: map['idcentro'] is int
          ? map['idcentro']
          : int.tryParse(map['idcentro']?.toString() ?? ''),
      foto: map['foto']?.toString(),
      geolocalizacion: map['geolocalizacion']?.toString(),
      fecha_hora_entrada: parseFecha(map['fecha_hora_entrada']),
      fecha_hora_salida: parseFecha(map['fecha_hora_salida']),
      solicitud: map['solicitud']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Fichaje.fromJson(String source) =>
      Fichaje.fromMap(json.decode(source) as Map<String, dynamic>);
}
