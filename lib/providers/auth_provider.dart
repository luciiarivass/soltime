import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../entities/login.dart';

class AuthProvider extends ChangeNotifier {
  Login? sesion;
  bool cargando = false;
  bool get isLogged => sesion != null;
  String get apikey => sesion?.apikey ?? '';
  bool? esAdmin;

  int? get idTrabajador => sesion?.idtrabajador;
  String get codcliente => sesion?.codcliente ?? '';
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

  Future<bool> restaurarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final apikey = prefs.getString('apikey');
    if (apikey == null || apikey.isEmpty) {
      return false;
    }
    sesion = Login()
      ..user = prefs.getString('user')
      ..apikey = apikey
      ..codcliente = prefs.getString('codcliente') ?? ''
      ..idtrabajador = prefs.getInt('idtrabajador');
    notifyListeners();

    return true;
  }

}
