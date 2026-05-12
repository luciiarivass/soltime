class Environment {
  static const dev = 'DEV';
  static const prod = 'PROD';
}

class Config {

  static const environment =
      Environment.dev;
      // o prod


  static const _devUrl =
      'http://31.97.37.249';

  static const _prodUrl =
      'https://gestion.soltime.es';


  static String get server {

    return environment ==
            Environment.dev
        ? _devUrl
        : _prodUrl;
  }


  static String get baseUrl =>
      '$server/api/3';
}