import 'dart:convert';
import 'package:http/http.dart' as http;

class Login {
  int? idlogin;
  int? idtrabajador;
  String codcliente = '';
  String? user;
  String apikey = '';
  bool passcambiado = false;

  Future<Login> login(String username, String password) async {
    final url = Uri.parse(
      'http://31.97.37.249/api/3/apikeyes?filter[description]=${Uri.encodeQueryComponent(username)}',
    );
    print("LOGIN URL -> $url");
    final response = await http.get(
      url,

      headers: {'Host': 'solpem.facturascripts.local', 'Token': password},
    );
    print("LOGIN RESPONSE -> ${response.statusCode}");
    print("LOGIN RESPONSE BODY -> ${response.body}");
    if (response.statusCode == 200) {
      final registro = json.decode(response.body);

      if (registro is List && registro.isNotEmpty) {
        final item = registro[0];

        if (item['apikey'] == password && item['enabled'] == true) {
          idlogin = item['id'];
          user = item['description']?.toString();
          apikey = item['apikey']?.toString() ?? '';
          codcliente = item['codcliente']?.toString() ?? '';
          passcambiado =
              item['passcambiado'] == true ||
              item['passcambiado'] == 1 ||
              item['passcambiado'] == '1';
          idtrabajador = int.tryParse(item['idtrabajador']?.toString() ?? '');

          return this;
        }
      }

      throw Exception('Usuario o contraseña incorrectos');
    } else {
      throw Exception('Usuario o contraseña incorrectos');
    }
  }
}
