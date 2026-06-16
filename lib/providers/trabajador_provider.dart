import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:solpem_app/config/environment.dart';
import 'package:mime/mime.dart';
import '../entities/fichaje.dart';
import '../entities/solicitud.dart';
import '../entities/tiposolicitud.dart';
import '../entities/trabajador.dart';

class TrabajadorProvider extends ChangeNotifier {
  String? apikey;
  int? idTrabajador;
  bool cargando = false;
  Trabajador? miInfo;
  List<Fichaje> misFichajes = [];
  List<Solicitud> misSolicitudes = [];
  List<Tiposolicitud> tiposSolicitudes = [];
  String? codcliente;
  Fichaje? fichajeAbierto;

  static const String _apiToken = 'TIDGZWcDtmkVu5ugzip6';

  Map<String, String> _headers() {
    return {
      'Host': 'solpem.facturascripts.local',
      'Token': _apiToken,
      if (apikey != null && apikey!.isNotEmpty) 'X-App-Token': apikey!,
    };
  }

  Map<String, String> _formHeaders() {
    return {
      'Host': 'solpem.facturascripts.local',
      'Token': _apiToken,
      if (apikey != null && apikey!.isNotEmpty) 'X-App-Token': apikey!,
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  bool get tieneFichajeAbierto => fichajeAbierto != null;

  Future<void> cargarMiArea({
    required String apikey,
    required int idTrabajador,
  }) async {
    this.apikey = apikey;
    this.idTrabajador = idTrabajador;

    cargando = true;
    notifyListeners();

    final url = Uri.parse('${Config.baseUrl}/app');

    try {
      final response = await http.get(url, headers: _headers());

      debugPrint('STATUS cargarMiArea: ${response.statusCode}');
      debugPrint('BODY cargarMiArea: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error cargando datos: ${response.body}');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      final info = data['info'] as Map<String, dynamic>?;

      miInfo = info != null ? Trabajador.fromMap(info) : null;
      codcliente = miInfo?.codcliente?.toString().trim();

      misFichajes = (data['fichajes'] as List? ?? [])
          .map((row) => Fichaje.fromMap(row as Map<String, dynamic>))
          .toList();

      misSolicitudes = (data['solicitudes'] as List? ?? [])
          .map((row) => Solicitud.fromMap(row as Map<String, dynamic>))
          .toList();

      tiposSolicitudes = (data['tipossolicitudes'] as List? ?? [])
          .map((row) => Tiposolicitud.fromMap(row as Map<String, dynamic>))
          .toList();

      misFichajes.sort((a, b) {
        final fechaA = a.fecha_hora_entrada ?? DateTime(1900);
        final fechaB = b.fecha_hora_entrada ?? DateTime(1900);
        return fechaB.compareTo(fechaA);
      });

      _actualizarFichajeAbierto();
    } catch (e, st) {
      debugPrint('Error en cargarMiArea: $e');
      debugPrint('$st');
    }

    cargando = false;
    notifyListeners();
  }

  Future<void> getTiposolicitudes() async {
    if (apikey == null) {
      return;
    }

    final url = Uri.parse('${Config.baseUrl}/tiposolicitudes');

    print('TIPOS URL -> $url');

    final response = await http.get(url, headers: _headers());

    print('TIPOS STATUS -> ${response.statusCode}');

    print('TIPOS BODY -> ${response.body}');

    if (response.statusCode != 200) {
      return;
    }

    final registros = json.decode(response.body) as List;

    tiposSolicitudes = registros.map((e) => Tiposolicitud.fromMap(e)).toList();

    notifyListeners();
  }

  Future<void> ficharEntrada({
    required int idtrabajador,
    required String codcliente,
    int? idcentro,
    String? foto,
    String? geolocalizacion,
    String? solicitud,
  }) async {
    if (apikey == null || apikey!.isEmpty) return;

    final url = Uri.parse('${Config.baseUrl}/app-fichaje');

    try {
      final response = await http.post(
        url,
        headers: _formHeaders(),
        body: {
          'idtrabajador': idtrabajador.toString(),
          'codcliente': codcliente,
          'fecha_hora_entrada': _formatearFechaHoraApi(DateTime.now()),
          if (idcentro != null) 'idcentro': idcentro.toString(),
          if (foto != null && foto.trim().isNotEmpty) 'foto': foto.trim(),
          if (geolocalizacion != null && geolocalizacion.trim().isNotEmpty)
            'geolocalizacion': geolocalizacion.trim(),
          if (solicitud != null && solicitud.trim().isNotEmpty)
            'solicitud': solicitud.trim(),
        },
      );

      debugPrint('STATUS ficharEntrada: ${response.statusCode}');
      debugPrint('BODY ficharEntrada: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (idTrabajador != null) {
          await cargarMiArea(apikey: apikey!, idTrabajador: idTrabajador!);
        }
      } else {
        debugPrint('Error al fichar entrada: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('Error en ficharEntrada: $e');
      debugPrint('$st');
    }
  }

  Future<void> ficharSalida() async {
  if (apikey == null || apikey!.isEmpty) return;
  if (fichajeAbierto?.idfichaje == null) return;

  final url = Uri.parse('${Config.baseUrl}/app-fichaje');

  final body = {
    'idfichaje': fichajeAbierto!.idfichaje.toString(),
    'fecha_hora_salida': _formatearFechaHoraApi(DateTime.now()),
  };

  try {
    final response = await http.put(
      url,
      headers: _formHeaders(),
      body: body,
    );

    debugPrint('URL SALIDA -> $url');
    debugPrint('BODY SALIDA -> $body');
    debugPrint('STATUS ficharSalida: ${response.statusCode}');
    debugPrint('BODY ficharSalida: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      await cargarMiArea(
        apikey: apikey!,
        idTrabajador: idTrabajador!,
      );

      notifyListeners();
      return;
    }

    throw Exception(
      'Error al fichar salida (${response.statusCode}): ${response.body}',
    );
  } catch (e, st) {
    debugPrint('Error en ficharSalida: $e');
    debugPrint('$st');
    rethrow;
  }
}

void _actualizarFichajeAbierto() {
  fichajeAbierto = null;

  for (final f in misFichajes) {
    if (f.fecha_hora_salida == null) {
      fichajeAbierto = f;
      break;
    }
  }
}

Future<void> crearSolicitud(
  Solicitud solicitud, {
  bool esFichaje = false,
  File? fichero,
}) async {
  final uri = Uri.parse('${Config.baseUrl}/app-solicitud');

  String formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return DateFormat('yyyy-MM-dd').format(fecha);
  }

  final codclienteFinal = solicitud.codcliente?.trim().isNotEmpty == true
      ? solicitud.codcliente!.trim()
      : codcliente?.trim();

  try {
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(_formHeaders());

    request.fields['estado'] = solicitud.estado?.trim().isNotEmpty == true
        ? solicitud.estado!.trim()
        : 'Pendiente';

    if (solicitud.aceptadaresponsable != null) {
      request.fields['aceptadaresponsable'] =
          solicitud.aceptadaresponsable! ? '1' : '0';
    }

    if (solicitud.aceptadatrabajador != null) {
      request.fields['aceptadatrabajador'] =
          solicitud.aceptadatrabajador! ? '1' : '0';
    }

    if (solicitud.fechainicio != null) {
      request.fields['fechainicio'] = formatearFecha(solicitud.fechainicio);
    } else if (esFichaje && solicitud.fechaHoraInicio != null) {
      request.fields['fechainicio'] = formatearFecha(
        solicitud.fechaHoraInicio,
      );
    }

    if (solicitud.fechafin != null) {
      request.fields['fechafin'] = formatearFecha(solicitud.fechafin);
    } else if (esFichaje && solicitud.fechaHoraFin != null) {
      request.fields['fechafin'] = formatearFecha(
        solicitud.fechaHoraFin,
      );
    }

    if (esFichaje && solicitud.fechaHoraInicio != null) {
      request.fields['fecha_hora_inicio'] = _formatearFechaHoraApi(
        solicitud.fechaHoraInicio!,
      );
    }

    if (esFichaje && solicitud.fechaHoraFin != null) {
      request.fields['fecha_hora_fin'] = _formatearFechaHoraApi(
        solicitud.fechaHoraFin!,
      );
    }

    if (solicitud.idtiposolicitud != null) {
      request.fields['idtiposolicitud'] =
          solicitud.idtiposolicitud.toString();
    }

    if (solicitud.idtrabajador != null) {
      request.fields['idtrabajador'] = solicitud.idtrabajador.toString();
    }

    if (codclienteFinal != null && codclienteFinal.isNotEmpty) {
      request.fields['codcliente'] = codclienteFinal;
    }

    if (solicitud.motivo?.trim().isNotEmpty == true) {
      request.fields['motivo'] = solicitud.motivo!.trim();
    }

    if (solicitud.observaciones?.trim().isNotEmpty == true) {
      request.fields['observaciones'] = solicitud.observaciones!.trim();
    }

    if (solicitud.adjunto?.trim().isNotEmpty == true) {
      request.fields['adjunto'] = solicitud.adjunto!.trim();
    }

    if (fichero != null) {
      final mimeType =
          lookupMimeType(fichero.path) ?? 'application/octet-stream';

      final partesMime = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'fichero',
          fichero.path,
          filename: fichero.path.split('/').last,
          contentType: http.MediaType(
            partesMime[0],
            partesMime.length > 1 ? partesMime[1] : 'octet-stream',
          ),
        ),
      );
    }

    debugPrint('URL crearSolicitud -> $uri');
    debugPrint('FIELDS crearSolicitud -> ${request.fields}');
    debugPrint('FILES crearSolicitud -> ${request.files.length}');

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    debugPrint('STATUS crearSolicitud: ${response.statusCode}');
    debugPrint('BODY crearSolicitud: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      await cargarMiArea(
        apikey: apikey!,
        idTrabajador: idTrabajador!,
      );

      notifyListeners();
      return;
    }

    throw Exception(
      'Error al crear solicitud (${response.statusCode}): ${response.body}',
    );
  } catch (e, st) {
    debugPrint('Error en crearSolicitud: $e');
    debugPrint('$st');
    rethrow;
  }
}

void clear() {
  apikey = null;
  idTrabajador = null;

  miInfo = null;
  misFichajes = [];
  misSolicitudes = [];
  tiposSolicitudes = [];
  fichajeAbierto = null;
  cargando = false;
  codcliente = null;

  notifyListeners();
}

Future<void> actualizarSolicitud(
  Solicitud solicitud, {
  bool esFichaje = false,
}) async {
  if (solicitud.idsolicitud == null) {
    throw Exception('La solicitud no tiene id');
  }

  if (apikey == null || apikey!.isEmpty) {
    throw Exception('No hay API key activa');
  }

  final url = Uri.parse('${Config.baseUrl}/app-solicitud');

  final codclienteFinal = solicitud.codcliente?.trim().isNotEmpty == true
      ? solicitud.codcliente!.trim()
      : codcliente?.trim();

  String estado = 'Pendiente';

  if (solicitud.aceptadatrabajador == false ||
      solicitud.aceptadaresponsable == false) {
    estado = 'Rechazada';
  } else if (solicitud.aceptadatrabajador == true &&
      solicitud.aceptadaresponsable == true) {
    estado = 'Aprobada';
  }

  try {
    final body = <String, String>{
      'idsolicitud': solicitud.idsolicitud.toString(),

      if (solicitud.idtrabajador != null)
        'idtrabajador': solicitud.idtrabajador.toString(),

      if (solicitud.idtiposolicitud != null)
        'idtiposolicitud': solicitud.idtiposolicitud.toString(),

      if (solicitud.fechainicio != null)
        'fechainicio': _formatearFechaApi(solicitud.fechainicio!),

      if (solicitud.fechafin != null)
        'fechafin': _formatearFechaApi(solicitud.fechafin!),

      if (codclienteFinal != null && codclienteFinal.isNotEmpty)
        'codcliente': codclienteFinal,

      if (esFichaje && solicitud.fechaHoraInicio != null)
        'fecha_hora_inicio': _formatearFechaHoraApi(
          solicitud.fechaHoraInicio!,
        ),

      if (esFichaje && solicitud.fechaHoraFin != null)
        'fecha_hora_fin': _formatearFechaHoraApi(
          solicitud.fechaHoraFin!,
        ),

      'estado': estado,

      if (solicitud.aceptadaresponsable != null)
        'aceptadaresponsable':
            solicitud.aceptadaresponsable! ? '1' : '0',

      if (solicitud.aceptadatrabajador != null)
        'aceptadatrabajador':
            solicitud.aceptadatrabajador! ? '1' : '0',

      if (solicitud.motivo != null) 'motivo': solicitud.motivo!,

      if (solicitud.observaciones != null)
        'observaciones': solicitud.observaciones!,

      if (solicitud.adjunto != null) 'adjunto': solicitud.adjunto!,
    };

    debugPrint('URL actualizarSolicitud: $url');
    debugPrint('BODY actualizarSolicitud: $body');

    final response = await http.put(
      url,
      headers: _formHeaders(),
      body: body,
    );

    debugPrint('STATUS actualizarSolicitud: ${response.statusCode}');
    debugPrint('BODY actualizarSolicitud: ${response.body}');

    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      await cargarMiArea(
        apikey: apikey!,
        idTrabajador: idTrabajador!,
      );

      notifyListeners();
      return;
    }

    throw Exception(
      'Error al actualizar solicitud (${response.statusCode}): ${response.body}',
    );
  } catch (e, st) {
    debugPrint('Error en actualizarSolicitud: $e');
    debugPrint('$st');
    rethrow;
  }
}

String _formatearFechaApi(DateTime fecha) {
  return '${fecha.year.toString().padLeft(4, '0')}-'
      '${fecha.month.toString().padLeft(2, '0')}-'
      '${fecha.day.toString().padLeft(2, '0')}';
}

String _formatearFechaHoraApi(DateTime fecha) {
  return '${fecha.year.toString().padLeft(4, '0')}-'
      '${fecha.month.toString().padLeft(2, '0')}-'
      '${fecha.day.toString().padLeft(2, '0')} '
      '${fecha.hour.toString().padLeft(2, '0')}:'
      '${fecha.minute.toString().padLeft(2, '0')}:'
      '${fecha.second.toString().padLeft(2, '0')}';
}
}
