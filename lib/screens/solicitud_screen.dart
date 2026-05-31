import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:solpem_app/entities/solicitud.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../entities/tiposolicitud.dart';
import '../providers/trabajador_provider.dart';

class SolicitudScreen extends StatefulWidget {
  const SolicitudScreen({super.key});

  @override
  State<SolicitudScreen> createState() => _SolicitudScreenState();
}

class _SolicitudScreenState extends State<SolicitudScreen> {
  File? _ficheroAdjunto;
  String? _nombreFichero;
  Tiposolicitud? tipoSeleccionado;
  DateTime? fechaInicio;
  DateTime? fechaFin;
  final _comentariosController = TextEditingController();

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  Future<void> _responderSolicitud(
    Solicitud solicitud, {
    required bool aceptar,
  }) async {
    final trabajador = context.read<TrabajadorProvider>();

    final solicitudActualizada = solicitud.copyWith(
      aceptadaresponsable: true,
      aceptadatrabajador: aceptar,
    );

    await trabajador.actualizarSolicitud(solicitudActualizada);

    if (trabajador.apikey != null && trabajador.idTrabajador != null) {
      await trabajador.cargarMiArea(
        apikey: trabajador.apikey!,
        idTrabajador: trabajador.idTrabajador!,
      );
    }

    if (!mounted) return;

    _mostrarMensaje(
      aceptar
          ? 'Solicitud aceptada correctamente'
          : 'Solicitud rechazada correctamente',
    );
  }

  void _mostrarDetalleSolicitudRecibida(Solicitud s) {
    final fmt = DateFormat('dd/MM/yyyy');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        'Solicitud recibida',
                        style: TextStyle(
                          color: const Color(0xFF0D5881),
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    Text(
                      'Fecha: ${s.fechainicio != null ? fmt.format(s.fechainicio!) : "-"}',
                      style: TextStyle(fontSize: 15.sp),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      'Motivo: ${s.motivo?.isNotEmpty == true ? s.motivo! : "-"}',
                      style: TextStyle(fontSize: 15.sp),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      'Observaciones: ${s.observaciones?.isNotEmpty == true ? s.observaciones! : "-"}',
                      style: TextStyle(fontSize: 15.sp),
                    ),

                    SizedBox(height: 28.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            await _responderSolicitud(s, aceptar: false);
                          },
                          child: CircleAvatar(
                            radius: 24.r,
                            backgroundColor: Colors.red,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                        ),

                        SizedBox(width: 28.w),

                        GestureDetector(
                          onTap: () async {
                            Navigator.pop(context);
                            await _responderSolicitud(s, aceptar: true);
                          },
                          child: CircleAvatar(
                            radius: 24.r,
                            backgroundColor: Colors.green,
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: CircleAvatar(
                    radius: 14.r,
                    backgroundColor: const Color(0xFFEDEDED),
                    child: Icon(Icons.close, size: 16.sp, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarSolicitudesRecibidas() {
    final trabajador = context.read<TrabajadorProvider>();

    final solicitudesRecibidas = trabajador.misSolicitudes.where((s) {
      return s.aceptadaresponsable == true && s.aceptadatrabajador == null;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        if (solicitudesRecibidas.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(24.w),
            child: Text(
              'No tienes solicitudes pendientes de responder.',
              style: TextStyle(fontSize: 15.sp),
            ),
          );
        }

        final fmt = DateFormat('dd/MM/yyyy');

        return Padding(
          padding: EdgeInsets.all(20.w),
          child: ListView.builder(
            itemCount: solicitudesRecibidas.length,
            itemBuilder: (_, index) {
              final s = solicitudesRecibidas[index];

              return Card(
                child: ListTile(
                  title: Text(
                    s.motivo?.isNotEmpty == true ? s.motivo! : 'Solicitud',
                  ),
                  subtitle: Text(
                    s.fechainicio != null
                        ? fmt.format(s.fechainicio!)
                        : 'Sin fecha',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    _mostrarDetalleSolicitudRecibida(s);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickFichero() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );

    if (result == null) return;

    final file = result.files.single;

    if (file.path == null) return;

    setState(() {
      _ficheroAdjunto = File(file.path!);
      _nombreFichero = file.name;
    });
  }

  void _mostrarMensaje(String texto, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto, textAlign: TextAlign.center),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          backgroundColor: error
              ? Colors.red
              : const Color.fromARGB(255, 13, 88, 129),
        ),
      );
  }

  Future<void> _enviarSolicitud() async {
    if (tipoSeleccionado == null && fechaInicio == null) {
      _mostrarMensaje("Selecciona motivo y fecha*", error: true);
      return;
    }

    if (tipoSeleccionado == null) {
      _mostrarMensaje("Selecciona un motivo*", error: true);
      return;
    }

    if (fechaInicio == null) {
      _mostrarMensaje("Selecciona una fecha*", error: true);
      return;
    }

    final trabajador = context.read<TrabajadorProvider>();

    final solicitud = Solicitud()
      ..idtrabajador = trabajador.idTrabajador
      ..codcliente = trabajador.miInfo?.codcliente
      ..idtiposolicitud = tipoSeleccionado!.idtiposolicitud
      ..fechainicio = fechaInicio
      ..fechafin = fechaFin ?? fechaInicio
      ..estado = 'Pendiente'
      ..motivo = _comentariosController.text.trim()
      ..aceptadaresponsable = null
      ..aceptadatrabajador = true;

    await trabajador.crearSolicitud(solicitud, fichero: _ficheroAdjunto);

    if (!mounted) return;

    _mostrarMensaje("Solicitud enviada correctamente");

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.pop(context);
  }

  Future<void> _seleccionarFechas() async {
    await showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 420,
            child: Column(
              children: [
                Text(
                  "Selecciona fecha",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SfDateRangePicker(
                    selectionMode: DateRangePickerSelectionMode.range,
                    backgroundColor: Colors.white,
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: const Color(
                        0xFF0D5881,
                      ).withOpacity(0.12),
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                        color: const Color(0xFF0D5881),
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selectionColor: const Color(0xFF0D5881),
                    startRangeSelectionColor: const Color(0xFF0D5881),
                    endRangeSelectionColor: const Color(0xFF0D5881),
                    rangeSelectionColor: const Color(
                      0xFF0D5881,
                    ).withOpacity(0.15),
                    todayHighlightColor: const Color(0xFF0D5881),
                    selectionTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    rangeTextStyle: const TextStyle(
                      color: Color(0xFF0D5881),
                      fontWeight: FontWeight.w600,
                    ),
                    monthCellStyle: const DateRangePickerMonthCellStyle(
                      todayTextStyle: TextStyle(
                        color: Color(0xFF0D5881),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onSelectionChanged: (args) {
                      if (args.value is PickerDateRange) {
                        final rango = args.value as PickerDateRange;

                        setState(() {
                          fechaInicio = rango.startDate;
                          fechaFin = rango.endDate ?? rango.startDate;
                        });
                      }
                    },
                  ),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5881).withOpacity(0.12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 28.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    "Aceptar",
                    style: TextStyle(
                      color: const Color(0xFF0D5881),
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final trabajador = context.watch<TrabajadorProvider>();

    final tipos = trabajador.tiposSolicitudes;

    final fmt = DateFormat("dd/MM/yyyy");

    final solicitudesPendientes = trabajador.misSolicitudes.where((s) {
      return s.aceptadaresponsable == true && s.aceptadatrabajador == null;
    }).length;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_solicitud.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 10.h,
                  left: 12.w,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 42.w,
                      height: 42.w,
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
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 10.h,
                  right: 12.w,
                  child: GestureDetector(
                    onTap: _mostrarSolicitudesRecibidas,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.w,
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
                          child: Icon(
                            Icons.pending_actions,
                            color: Colors.black,
                            size: 22.sp,
                          ),
                        ),

                        if (solicitudesPendientes > 0)
                          Positioned(
                            top: -4.h,
                            right: -4.w,
                            child: Container(
                              width: 18.w,
                              height: 18.w,
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                solicitudesPendientes > 9
                                    ? '9+'
                                    : '$solicitudesPendientes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  top: 155.h,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/icon_solicitud.png',
                            width: 24.w,
                          ),

                          SizedBox(width: 8.w),

                          Text(
                            "Motivo de solicitud",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      GestureDetector(
                        onTap: () {
                          _mostrarTipos(tipos);
                        },
                        child: _buildCaja(
                          child: Text(
                            tipoSeleccionado?.nombre ?? '-',
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  top: 300.h,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/calendario_solicitud.png',
                            width: 24.w,
                          ),

                          SizedBox(width: 8.w),

                          Text("Fechas", style: TextStyle(fontSize: 16.sp)),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      GestureDetector(
                        onTap: _seleccionarFechas,
                        child: _buildCaja(
                          child: Text(
                            fechaInicio == null
                                ? '-'
                                : fechaInicio == fechaFin
                                ? fmt.format(fechaInicio!)
                                : '${fmt.format(fechaInicio!)} - ${fmt.format(fechaFin!)}',
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromARGB(255, 13, 88, 129),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  top: 445.h,
                  child: Column(
                    children: [
                      SizedBox(height: 6.h),
                      _buildCajaComentarios(),
                    ],
                  ),
                ),

                Positioned(
                  left: 35.w,
                  right: 35.w,
                  bottom: 155.h,
                  child: GestureDetector(
                    onTap: () => _confirmarEnvio(),
                    child: Image.asset(
                      'assets/images/boton_solicitud.png',
                      height: 95.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarTipos(List<Tiposolicitud> tipos) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView(
              shrinkWrap: true,
              children: tipos.map((tipo) {
                return ListTile(
                  title: Text(
                    tipo.nombre ?? '',
                    style: TextStyle(
                      color: const Color(0xFF0D5881),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      tipoSeleccionado = tipo;
                    });

                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCaja({required Widget child}) {
    return SizedBox(
      width: 260.w * 1.6,
      height: 62.h * 1.6,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset('assets/images/caja_solicitud.png', fit: BoxFit.contain),
          child,
        ],
      ),
    );
  }

  Widget _buildCajaComentarios() {
    return Container(
      width: 180.w * 1.6,
      height: 90.h,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 242, 240, 240),
        borderRadius: BorderRadius.circular(35.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16.h,
            right: 18.w,
            child: GestureDetector(
              onTap: _pickFichero,
              child: Icon(
                Icons.attach_file,
                color: const Color(0xFF0D5881),
                size: 22.sp,
              ),
            ),
          ),

          if (_nombreFichero != null)
            Positioned(
              top: 10.h,
              left: 24.w,
              right: 55.w,
              child: Text(
                _nombreFichero!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color.fromARGB(255, 77, 76, 76),
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 55.w,
              top: _nombreFichero != null ? 28.h : 18.h,
              bottom: 18.h,
            ),
            child: TextField(
              controller: _comentariosController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Añade comentarios...",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 15.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmarEnvio() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Enviar solicitud',
            style: TextStyle(
              color: const Color(0xFF0D5881),
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          content: Text(
            '¿Seguro que quieres enviar la solicitud?',
            style: TextStyle(fontSize: 15.sp),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(
                'Enviar',
                style: TextStyle(
                  color: const Color(0xFF0D5881),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    await _enviarSolicitud();
  }
}
