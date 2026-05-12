import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:solpem_app/providers/auth_provider.dart';

import '../entities/fichaje.dart';
import '../entities/solicitud.dart';
import '../providers/trabajador_provider.dart';

class FicharScreen extends StatefulWidget {
  const FicharScreen({super.key});

  @override
  State<FicharScreen> createState() => _FicharScreenState();
}

class _FicharScreenState extends State<FicharScreen> {
  static const Color amarillo = Color(0xFFFAC02E);

  Duration _tiempo = Duration.zero;
  Timer? _timer;
  int? _ultimoFichajeId;
  bool _cargandoAccion = false;
  String _tipoFiltro = 'todos';
  bool _masRecientesPrimero = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sincronizarTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sincronizarTimer() {
    final provider = context.read<TrabajadorProvider>();

    final abierto = provider.fichajeAbierto;

    final nuevoId = abierto?.idfichaje;

    if (_ultimoFichajeId == nuevoId && _timer?.isActive == true) {
      return;
    }

    _ultimoFichajeId = nuevoId;

    _timer?.cancel();

    if (abierto == null || abierto.fecha_hora_entrada == null) {
      if (mounted) {
        setState(() {
          _tiempo = Duration.zero;
        });
      }

      return;
    }

    void actualizar() {
      final entrada = abierto.fecha_hora_entrada!;

      final diff = DateTime.now().difference(entrada);

      if (mounted) {
        setState(() {
          _tiempo = diff.isNegative ? Duration.zero : diff;
        });
      }
    }

    actualizar();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => actualizar());
  }

  Future<void> _toggleJornada() async {
    if (_cargandoAccion) {
      return;
    }

    final trabajadorProvider = context.read<TrabajadorProvider>();

    final authProvider = context.read<AuthProvider>();

    final esEntrada = !trabajadorProvider.tieneFichajeAbierto;

    final int? idtrabajador =
        authProvider.idTrabajadorSesion ??
        trabajadorProvider.miInfo?.idtrabajador;

    final trabajadorLogueado = trabajadorProvider.miInfo;

    final String codcliente = trabajadorLogueado?.codcliente ?? '';

    final int? idcentro = trabajadorLogueado?.idcentro;

    if (esEntrada && (idtrabajador == null || codcliente.trim().isEmpty)) {
      return;
    }

    setState(() {
      _cargandoAccion = true;
    });

    try {
      // ENTRADA
      if (esEntrada) {
        await trabajadorProvider.ficharEntrada(
          idtrabajador: idtrabajador!,
          codcliente: codcliente,
          idcentro: idcentro,
        );

        setState(() {
          _tiempo = Duration.zero;
        });

        _sincronizarTimer();
      }
      // SALIDA
      else {
        _timer?.cancel();

        await trabajadorProvider.ficharSalida();

        // recargar datos
        await trabajadorProvider.cargarMiArea(
          apikey: authProvider.apikey,
          idTrabajador: idtrabajador!,
        );

        setState(() {
          _tiempo = Duration.zero;
        });
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            esEntrada
                ? 'Entrada registrada correctamente'
                : 'Salida registrada correctamente',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _cargandoAccion = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _registros(TrabajadorProvider provider) {
    final lista = <Map<String, dynamic>>[];

    if (_tipoFiltro == 'todos' || _tipoFiltro == 'fichajes') {
      for (final f in provider.misFichajes) {
        if (f.fecha_hora_entrada == null) continue;

        lista.add({
          'tipo': 'fichaje',
          'fecha': f.fecha_hora_entrada,
          'data': f,
        });
      }
    }

    if (_tipoFiltro == 'todos' || _tipoFiltro == 'solicitudes') {
      for (final s in provider.misSolicitudes) {
        if (s.fechainicio == null) continue;

        lista.add({'tipo': 'solicitud', 'fecha': s.fechainicio, 'data': s});
      }
    }

    lista.sort((a, b) {
      final fa = a['fecha'] as DateTime;
      final fb = b['fecha'] as DateTime;

      return _masRecientesPrimero ? fb.compareTo(fa) : fa.compareTo(fb);
    });

    return lista;
  }

  String _timerText() {
    final h = _tiempo.inHours.toString().padLeft(2, '0');

    final m = (_tiempo.inMinutes % 60).toString().padLeft(2, '0');

    final s = (_tiempo.inSeconds % 60).toString().padLeft(2, '0');

    return '$h:$m:$s';
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'Finalizada':
        return Colors.red;

      case 'Pendiente':
        return amarillo;

      default:
        return const Color(0xFF0D5881);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TrabajadorProvider>();
    final registros = _registros(provider);

    final hayAbierto = provider.tieneFichajeAbierto;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _sincronizarTimer();
      }
    });
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_trabajadores.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: const Text(
                      'Registro de jornadas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,

                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),

                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),

                            blurRadius: 12,

                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.arrow_back_ios_new,

                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 12,

                  child: GestureDetector(
                    onTap: _mostrarFiltros,

                    child: Container(
                      width: 42,
                      height: 42,

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),

                        shape: BoxShape.circle,

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: const Icon(
                        Icons.tune,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(height: 60),

                    Padding(
                      padding: const EdgeInsets.all(20),

                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _toggleJornada,

                              child: Container(
                                height: 62,

                                decoration: BoxDecoration(
                                  color: hayAbierto ? Colors.red : amarillo,

                                  borderRadius: BorderRadius.circular(32),
                                ),

                                child: Center(
                                  child: _cargandoAccion
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          hayAbierto ? 'SALIR' : 'ENTRAR',

                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 20),

                          Text(
                            _timerText(),

                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D5881),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                        child: SingleChildScrollView(
                          child: DataTable(
                            horizontalMargin: 4,

                            columns: [
                              DataColumn(label: _heading('Estado')),
                              DataColumn(label: _heading('Fecha')),
                              DataColumn(label: _heading('Inicio')),
                              DataColumn(label: _heading('Fin')),
                            ],

                            rows: registros.asMap().entries.map((entry) {
                              final index = entry.key;
                              final r = entry.value;

                              final colorFila = index.isEven
                                  ? Colors.white
                                  : const Color(0xFF0D5881).withOpacity(0.16);

                              // FICHAJES
                              if (r['tipo'] == 'fichaje') {
                                final f = r['data'] as Fichaje;

                                final estado = f.fecha_hora_salida == null
                                    ? 'En curso'
                                    : 'Finalizada';

                                return DataRow(
                                  color: WidgetStateProperty.all(colorFila),

                                  cells: [
                                    DataCell(_chip(estado)),

                                    DataCell(
                                      Text(
                                        DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(f.fecha_hora_entrada!),
                                      ),
                                    ),

                                    DataCell(
                                      Text(
                                        DateFormat(
                                          'HH:mm',
                                        ).format(f.fecha_hora_entrada!),
                                      ),
                                    ),

                                    DataCell(
                                      Text(
                                        f.fecha_hora_salida == null
                                            ? '--'
                                            : DateFormat(
                                                'HH:mm',
                                              ).format(f.fecha_hora_salida!),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              // SOLICITUDES
                              final s = r['data'] as Solicitud;

                              return DataRow(
                                color: WidgetStateProperty.all(colorFila),

                                cells: [
                                  DataCell(
                                    _chip(s.estado ?? 'Pendiente'),
                                    onTap: () => _mostrarDetalleSolicitud(s),
                                  ),

                                  DataCell(
                                    Text(
                                      DateFormat(
                                        'dd/MM/yyyy',
                                      ).format(s.fechainicio!),
                                    ),
                                    onTap: () => _mostrarDetalleSolicitud(s),
                                  ),

                                  DataCell(
                                    const Text('--'),
                                    onTap: () => _mostrarDetalleSolicitud(s),
                                  ),

                                  DataCell(
                                    const Text('--'),
                                    onTap: () => _mostrarDetalleSolicitud(s),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarFiltros() {
    const azulApp = Color(0xFF0D5881);

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Theme(
            data: Theme.of(context).copyWith(
              radioTheme: RadioThemeData(
                fillColor: WidgetStateProperty.all(azulApp),
              ),

              switchTheme: SwitchThemeData(
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return azulApp;
                  }

                  return Colors.grey.shade400;
                }),

                trackColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return azulApp.withOpacity(0.25);
                  }

                  return Colors.grey.shade300;
                }),
              ),
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Text(
                  'Filtros',

                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: azulApp,
                  ),
                ),

                const SizedBox(height: 20),

                RadioListTile<String>(
                  activeColor: azulApp,

                  title: const Text("Todos"),

                  value: 'todos',

                  groupValue: _tipoFiltro,

                  onChanged: (value) {
                    setState(() {
                      _tipoFiltro = value!;
                    });

                    Navigator.pop(context);
                  },
                ),

                RadioListTile<String>(
                  activeColor: azulApp,

                  title: const Text("Solo fichajes"),

                  value: 'fichajes',

                  groupValue: _tipoFiltro,

                  onChanged: (value) {
                    setState(() {
                      _tipoFiltro = value!;
                    });

                    Navigator.pop(context);
                  },
                ),

                RadioListTile<String>(
                  activeColor: azulApp,

                  title: const Text("Solo solicitudes"),

                  value: 'solicitudes',

                  groupValue: _tipoFiltro,

                  onChanged: (value) {
                    setState(() {
                      _tipoFiltro = value!;
                    });

                    Navigator.pop(context);
                  },
                ),

                SwitchListTile(
                  activeColor: azulApp,

                  activeTrackColor: azulApp.withOpacity(0.25),

                  title: const Text("Más recientes primero"),

                  value: _masRecientesPrimero,

                  onChanged: (value) {
                    setState(() {
                      _masRecientesPrimero = value;
                    });

                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarDetalleSolicitud(Solicitud s) {
    final fmt = DateFormat("dd/MM/yyyy");

    showDialog(
      context: context,

      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: const Text(
            'Solicitud',

            style: TextStyle(
              color: Color(0xFF0D5881),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text('Estado: ${s.estado ?? "-"}'),

              const SizedBox(height: 8),

              Text(
                'Fecha: ${s.fechainicio != null ? fmt.format(s.fechainicio!) : "-"}'
                '${s.fechafin != null && s.fechafin != s.fechainicio ? " - ${fmt.format(s.fechafin!)}" : ""}',
              ),

              const SizedBox(height: 8),

              Text('Motivo: ${s.motivo?.isNotEmpty == true ? s.motivo! : "-"}'),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text(
                'Cerrar',

                style: TextStyle(
                  color: Color(0xFF0D5881),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chip(String estado) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

      decoration: BoxDecoration(
        color: _estadoColor(estado),

        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        estado,

        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _heading(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.bold));
  }
}
