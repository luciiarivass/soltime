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

  Fichaje? fichajeAbierto;

  Map<String, String> _headers() {
    return {'Host': 'solpem.facturascripts.local', 'Token': apikey ?? ''};
  }

  Map<String, String> _formHeaders() {
    return {
      'Host': 'solpem.facturascripts.local',
      'Token': apikey ?? '',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
  }

  bool get tieneFichajeAbierto => fichajeAbierto != null;

  Future<void> cargarMiArea({
    required String apikey,
    required int idTrabajador,
  }) async {
    print('========== CARGAR MI AREA ==========');

    this.apikey = apikey;
    this.idTrabajador = idTrabajador;

    cargando = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        '${Config.baseUrl}/trabajadorporid?idtrabajador=$idTrabajador',
      );

      print('URL -> $url');

      print('HEADERS -> ${_headers()}');

      final response = await http.get(url, headers: _headers());

      print('STATUS -> ${response.statusCode}');

      print('BODY -> ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Error cargando trabajador');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;

      print('JSON OK');

      miInfo = data['info'] != null ? Trabajador.fromMap(data['info']) : null;

      print('TRABAJADOR -> ${miInfo?.idtrabajador}');

      misFichajes = data['fichajes'] != null
          ? (data['fichajes'] as List).map((e) => Fichaje.fromMap(e)).toList()
          : [];

      print('FICHAJES -> ${misFichajes.length}');

      misSolicitudes = data['solicitudes'] != null
          ? (data['solicitudes'] as List)
                .map((e) => Solicitud.fromMap(e))
                .toList()
          : [];

      print('SOLICITUDES -> ${misSolicitudes.length}');

      misFichajes.sort((a, b) {
        final fa = a.fecha_hora_entrada ?? DateTime(1900);

        final fb = b.fecha_hora_entrada ?? DateTime(1900);

        return fb.compareTo(fa);
      });

      _actualizarFichajeAbierto();

      print('FICHAJE ABIERTO -> ${fichajeAbierto?.idfichaje}');

      if (tiposSolicitudes.isEmpty) {
        await getTiposolicitudes();
      }

      print('========== OK ==========');
    } catch (e) {
      print('ERROR cargarMiArea -> $e');

      rethrow;
    } finally {
      cargando = false;

      notifyListeners();
    }
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

    final url = Uri.parse('${Config.baseUrl}/fichajes');

    try {
      final response = await http.post(
        url,
        headers: _formHeaders(),
        body: {
          'idtrabajador': idtrabajador.toString(),
          'codcliente': codcliente,
          'fecha_hora_salida': 'null',
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

    final url = Uri.parse(
      '${Config.baseUrl}/fichajes/${fichajeAbierto!.idfichaje}',
    );

    final ahora = DateTime.now();

    final fechaFormateada =
        '${ahora.year.toString().padLeft(4, '0')}-'
        '${ahora.month.toString().padLeft(2, '0')}-'
        '${ahora.day.toString().padLeft(2, '0')} '
        '${ahora.hour.toString().padLeft(2, '0')}:'
        '${ahora.minute.toString().padLeft(2, '0')}:'
        '${ahora.second.toString().padLeft(2, '0')}';

    try {
      final response = await http.put(
        url,
        headers: _formHeaders(),
        body: {'fecha_hora_salida': fechaFormateada},
      );

      print('URL SALIDA -> $url');
      print('BODY ENVIADO -> $fechaFormateada');
      print('STATUS SALIDA -> ${response.statusCode}');
      print('BODY SALIDA -> ${response.body}');
      debugPrint('STATUS ficharSalida: ${response.statusCode}');
      debugPrint('BODY ficharSalida: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (idTrabajador != null) {
          await cargarMiArea(apikey: apikey!, idTrabajador: idTrabajador!);
        }
      } else {
        debugPrint('Error al fichar salida: ${response.statusCode}');
      }
    } catch (e, st) {
      debugPrint('Error en ficharSalida: $e');
      debugPrint('$st');
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
  final uri = Uri.parse('${Config.baseUrl}/solicitudes');

  String formatearFecha(DateTime? fecha) {
    if (fecha == null) return '';
    return DateFormat('yyyy-MM-dd').format(fecha);
  }

  try {
    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll(_formHeaders());

    if (solicitud.estado?.trim().isNotEmpty == true) {
      request.fields['estado'] = solicitud.estado!.trim();
    }

    if (solicitud.fechainicio != null) {
      request.fields['fechainicio'] =
          formatearFecha(solicitud.fechainicio);
    }

    if (solicitud.fechafin != null) {
      request.fields['fechafin'] =
          formatearFecha(solicitud.fechafin);
    }

    if (esFichaje && solicitud.fechaHoraInicio != null) {
      request.fields['fecha_hora_inicio'] =
          _formatearFechaHoraApi(
        solicitud.fechaHoraInicio!,
      );
    }

    if (esFichaje && solicitud.fechaHoraFin != null) {
      request.fields['fecha_hora_fin'] =
          _formatearFechaHoraApi(
        solicitud.fechaHoraFin!,
      );
    }

    if (solicitud.idtiposolicitud != null) {
      request.fields['idtiposolicitud'] =
          solicitud.idtiposolicitud.toString();
    }

    if (solicitud.idtrabajador != null) {
      request.fields['idtrabajador'] =
          solicitud.idtrabajador.toString();
    }

    if (solicitud.codcliente?.trim().isNotEmpty == true) {
      request.fields['codcliente'] =
          solicitud.codcliente!.trim();
    }

    if (solicitud.motivo?.trim().isNotEmpty == true) {
      request.fields['motivo'] =
          solicitud.motivo!.trim();
    }

    if (solicitud.observaciones?.trim().isNotEmpty == true) {
      request.fields['observaciones'] =
          solicitud.observaciones!.trim();
    }

    // ADJUNTO OPCIONAL
    if (fichero != null) {
      final mimeType =
          lookupMimeType(fichero.path) ??
              'application/octet-stream';

      request.files.add(
        await http.MultipartFile.fromPath(
          'fichero',
          fichero.path,
          filename: fichero.path.split('/').last,
          contentType: http.MediaType(
            mimeType.split('/')[0],
            mimeType.split('/')[1],
          ),
        ),
      );

      print('FICHERO: ${fichero.path}');
    }

    print('FIELDS: ${request.fields}');
    print('FILES: ${request.files.length}');

    final streamed = await request.send();

    final response =
        await http.Response.fromStream(streamed);

    print('STATUS: ${response.statusCode}');
    print('RESPONSE: ${response.body}');

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      await cargarMiArea(
        apikey: apikey!,
        idTrabajador: idTrabajador!,
      );

      notifyListeners();

      return;
    }

    throw Exception(
      'Error al crear solicitud '
      '(${response.statusCode}): '
      '${response.body}',
    );
  } catch (e, st) {
    print('Error en crearSolicitud: $e');
    print(st);
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

    notifyListeners();
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
