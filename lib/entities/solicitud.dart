import 'dart:convert';
import 'package:intl/intl.dart';

class Solicitud {
  int? idsolicitud;
  int? idtrabajador;
  int? idtiposolicitud;
  DateTime? fechainicio;
  DateTime? fechafin;
  DateTime? fechaHoraInicio;
  DateTime? fechaHoraFin;
  String? adjunto;
  String? observaciones;
  String? motivo;
  String? estado;
  String? codcliente;
  bool? aceptadaresponsable;
  bool? aceptadatrabajador;

  Solicitud({
    this.idsolicitud,
    this.idtrabajador,
    this.idtiposolicitud,
    this.fechainicio,
    this.fechafin,
    this.fechaHoraInicio,
    this.fechaHoraFin,
    this.adjunto,
    this.observaciones,
    this.motivo,
    this.estado,
    this.codcliente,
    this.aceptadaresponsable,
    this.aceptadatrabajador,
  });

  Solicitud copyWith({
    int? idsolicitud,
    int? idtrabajador,
    int? idtiposolicitud,
    DateTime? fechainicio,
    DateTime? fechafin,
    DateTime? fechaHoraInicio,
    DateTime? fechaHoraFin,
    String? adjunto,
    String? observaciones,
    String? motivo,
    String? estado,
    String? codcliente,
    bool? aceptadaresponsable,
    bool? aceptadatrabajador,
  }) {
    return Solicitud(
      idsolicitud: idsolicitud ?? this.idsolicitud,
      idtrabajador: idtrabajador ?? this.idtrabajador,
      idtiposolicitud: idtiposolicitud ?? this.idtiposolicitud,
      fechainicio: fechainicio ?? this.fechainicio,
      fechafin: fechafin ?? this.fechafin,
      fechaHoraInicio: fechaHoraInicio ?? this.fechaHoraInicio,
      fechaHoraFin: fechaHoraFin ?? this.fechaHoraFin,
      adjunto: adjunto ?? this.adjunto,
      observaciones: observaciones ?? this.observaciones,
      motivo: motivo ?? this.motivo,
      estado: estado ?? this.estado,
      codcliente: codcliente ?? this.codcliente,
      aceptadaresponsable: aceptadaresponsable ?? this.aceptadaresponsable,
      aceptadatrabajador: aceptadatrabajador ?? this.aceptadatrabajador,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idsolicitud': idsolicitud,
      'idtrabajador': idtrabajador,
      'idtiposolicitud': idtiposolicitud,
      'fechainicio': fechainicio?.millisecondsSinceEpoch,
      'fechafin': fechafin?.millisecondsSinceEpoch,
      'fecha_hora_inicio': fechaHoraInicio?.millisecondsSinceEpoch,
      'fecha_hora_fin': fechaHoraFin?.millisecondsSinceEpoch,
      'adjunto': adjunto,
      'observaciones': observaciones,
      'motivo': motivo,
      'estado': estado,
      'codcliente': codcliente,
      'aceptadaresponsable': aceptadaresponsable,
      'aceptadatrabajador': aceptadatrabajador,
    };
  }

  factory Solicitud.fromMap(Map<String, dynamic> map) {
    DateTime? parseFecha(dynamic value) {
      if (value == null) return null;

      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }

      final texto = value.toString().trim();
      if (texto.isEmpty) return null;

      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(texto);
      } catch (_) {}

      try {
        return DateFormat('yyyy-MM-dd').parseStrict(texto);
      } catch (_) {}

      try {
        return DateFormat('dd-MM-yyyy HH:mm:ss').parseStrict(texto);
      } catch (_) {}

      try {
        return DateFormat('dd-MM-yyyy').parseStrict(texto);
      } catch (_) {}

      try {
        return DateFormat('dd/MM/yyyy HH:mm:ss').parseStrict(texto);
      } catch (_) {}

      try {
        return DateFormat('dd/MM/yyyy').parseStrict(texto);
      } catch (_) {}

      return DateTime.tryParse(texto);
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;

      if (value is bool) return value;

      if (value is int) return value == 1;

      final texto = value.toString().trim().toLowerCase();

      if (texto == '1' || texto == 'true') {
        return true;
      }

      if (texto == '0' || texto == 'false') {
        return false;
      }

      return null;
    }

    return Solicitud(
      idsolicitud: map['idsolicitud'] is int
          ? map['idsolicitud']
          : int.tryParse(map['idsolicitud']?.toString() ?? ''),
      idtrabajador: map['idtrabajador'] is int
          ? map['idtrabajador']
          : int.tryParse(map['idtrabajador']?.toString() ?? ''),
      idtiposolicitud: map['idtiposolicitud'] is int
          ? map['idtiposolicitud']
          : int.tryParse(map['idtiposolicitud']?.toString() ?? ''),
      fechainicio: parseFecha(map['fechainicio']),
      fechafin: parseFecha(map['fechafin']),
      fechaHoraInicio: parseFecha(map['fecha_hora_inicio']),
      fechaHoraFin: parseFecha(map['fecha_hora_fin']),
      adjunto: map['adjunto']?.toString(),
      observaciones: map['observaciones']?.toString(),
      motivo: map['motivo']?.toString(),
      estado: map['estado']?.toString(),
      codcliente: map['codcliente']?.toString(),
      aceptadaresponsable: parseBool(map['aceptadaresponsable']),

      aceptadatrabajador: parseBool(map['aceptadatrabajador']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Solicitud.fromJson(String source) =>
      Solicitud.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Solicitud(idsolicitud: $idsolicitud, idtrabajador: $idtrabajador, idtiposolicitud: $idtiposolicitud, fechainicio: $fechainicio, fechafin: $fechafin, fechaHoraInicio: $fechaHoraInicio, fechaHoraFin: $fechaHoraFin, adjunto: $adjunto, observaciones: $observaciones, motivo: $motivo, estado: $estado, codcliente: $codcliente), aceptadaresponsable: $aceptadaresponsable, aceptadatrabajador: $aceptadatrabajador)';
  }

  @override
  bool operator ==(covariant Solicitud other) {
    if (identical(this, other)) return true;

    return other.idsolicitud == idsolicitud &&
        other.idtrabajador == idtrabajador &&
        other.idtiposolicitud == idtiposolicitud &&
        other.fechainicio == fechainicio &&
        other.fechafin == fechafin &&
        other.fechaHoraInicio == fechaHoraInicio &&
        other.fechaHoraFin == fechaHoraFin &&
        other.adjunto == adjunto &&
        other.observaciones == observaciones &&
        other.motivo == motivo &&
        other.estado == estado &&
        other.codcliente == codcliente &&
        other.aceptadaresponsable == aceptadaresponsable &&
        other.aceptadatrabajador == aceptadatrabajador;
  }

  @override
  int get hashCode {
    return idsolicitud.hashCode ^
        idtrabajador.hashCode ^
        idtiposolicitud.hashCode ^
        fechainicio.hashCode ^
        fechafin.hashCode ^
        fechaHoraInicio.hashCode ^
        fechaHoraFin.hashCode ^
        adjunto.hashCode ^
        observaciones.hashCode ^
        motivo.hashCode ^
        estado.hashCode ^
        codcliente.hashCode ^
        aceptadaresponsable.hashCode ^
        aceptadatrabajador.hashCode;
  }
}
