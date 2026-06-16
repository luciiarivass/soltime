import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:solpem_app/config/environment.dart';

class Login {
  int? idlogin;
  int? idtrabajador;
  String codcliente = '';
  String? user;
  String apikey = '';
  bool passcambiado = false;

  Future<Login> login(String username, String password) async {
    final url = Uri.parse('${Config.baseUrl}/auth');

    print("LOGIN URL -> $url");

    final response = await http.post(
      url,
      headers: {
        'Host': 'solpem.facturascripts.local',
        'Token': 'TIDGZWcDtmkVu5ugzip6',
      },
      body: {
        'login': username,
        'password': password,
      },
    );

    print("LOGIN RESPONSE -> ${response.statusCode}");
    print("LOGIN RESPONSE BODY -> ${response.body}");

    if (response.statusCode == 200) {
      final registro = json.decode(response.body);

      final item = registro is List && registro.isNotEmpty
          ? registro[0]
          : registro is Map<String, dynamic>
              ? registro
              : null;

      if (item != null) {
        final usuario = item['usuario'];

        idlogin = int.tryParse(item['id']?.toString() ?? '');
        user = usuario?['login']?.toString();
        apikey = item['token']?.toString() ?? '';
        codcliente = usuario?['codcliente']?.toString() ?? '';

        passcambiado =
            item['debe_cambiar_password'] == true ||
            usuario?['passcambiado'] == true ||
            usuario?['passcambiado'] == 1 ||
            usuario?['passcambiado']?.toString() == '1';

        idtrabajador = int.tryParse(
          usuario?['idtrabajador']?.toString() ?? '',
        );

        return this;
      }
    }

    throw Exception('Usuario o contraseña incorrectos');
  }
}