import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solpem_app/config/environment.dart';

import '../entities/login.dart';

class AuthProvider extends ChangeNotifier {
  Login? sesion;
  bool cargando = false;

  bool get isLogged => sesion != null;
  String get apikey => sesion?.apikey ?? '';
  int? get idTrabajador => sesion?.idtrabajador;
  String get codcliente => sesion?.codcliente ?? '';

  bool? esAdmin;
  int? idTrabajadorSesion;

  Future<void> login(String user, String pass) async {
    cargando = true;
    notifyListeners();

    try {
      final login = await Login().login(user, pass);

      sesion = login;
      idTrabajadorSesion = login.idtrabajador;

      await _guardarSesion();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> _guardarSesion() async {
    if (sesion == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user', sesion!.user ?? '');
    await prefs.setString('apikey', sesion!.apikey);
    await prefs.setString('codcliente', sesion!.codcliente);
    await prefs.setInt('idtrabajador', sesion!.idtrabajador ?? 0);
  }

  Future<void> cambiarPassword({
    required String actual,
    required String nueva,
  }) async {
    if (apikey.isEmpty) {
      throw Exception('No hay sesión activa');
    }

    try {
      final url = Uri.parse('${Config.baseUrl}/auth');

      debugPrint('URL cambiarPassword: $url');

      final response = await http.put(
        url,
        headers: {
          'Host': 'solpem.facturascripts.local',
          'Token': 'TIDGZWcDtmkVu5ugzip6',
          'X-App-Token': apikey,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'accion': 'cambiar-password',
          'password_actual': actual,
          'nuevo_password': nueva,
        },
      );

      debugPrint('STATUS cambiarPassword: ${response.statusCode}');
      debugPrint('BODY cambiarPassword: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (sesion != null) {
          sesion!.passcambiado = true;
        }

        notifyListeners();
        return;
      }

      throw Exception(
        'Error al cambiar contraseña (${response.statusCode}): ${response.body}',
      );
    } catch (e, st) {
      debugPrint('ERROR cambiarPassword: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<bool> restaurarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    final apikeyGuardada = prefs.getString('apikey');

    if (apikeyGuardada == null || apikeyGuardada.isEmpty) {
      return false;
    }

    sesion = Login()
      ..user = prefs.getString('user')
      ..apikey = apikeyGuardada
      ..codcliente = prefs.getString('codcliente') ?? ''
      ..idtrabajador = prefs.getInt('idtrabajador');

    idTrabajadorSesion = sesion?.idtrabajador;

    notifyListeners();

    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    sesion = null;
    idTrabajadorSesion = null;
    esAdmin = null;
    cargando = false;

    notifyListeners();
  }
}