import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:solpem_app/providers/auth_provider.dart';
import 'package:solpem_app/screens/login_screen.dart';

import '../providers/trabajador_provider.dart';

import 'solicitud_screen.dart';
import 'fichar_screen.dart';

class TrabajadorScreen extends StatelessWidget {
  const TrabajadorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trabajador = context.watch<TrabajadorProvider>();

    final info = trabajador.miInfo;
    final solicitudesPendientes = trabajador.misSolicitudes.where((s) {
      return s.aceptadaresponsable == true && s.aceptadatrabajador == null;
    }).length;
    final nombre = info?.nombre ?? '';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_trabajador.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                // PERFIL
                Positioned(
                  left: 70.w,
                  right: 70.w,
                  top: 35.h,

                  child: SizedBox(
                    height: 95.h,

                    child: Center(
                      child: Text(
                        nombre,

                        textAlign: TextAlign.center,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: TextStyle(
                          fontSize: 24.sp,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF222222),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10.h,
                  right: 12.w,

                  child: PopupMenuButton<String>(
                    color: Colors.white,

                    elevation: 8,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),

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
                        Icons.more_vert,

                        color: const Color.fromARGB(255, 0, 0, 0),

                        size: 20.sp,
                      ),
                    ),

                    onSelected: (value) async {
                      if (value != 'logout') {
                        return;
                      }

                      final confirmar = await showDialog<bool>(
                        context: context,

                        builder: (_) {
                          return AlertDialog(
                            backgroundColor: Colors.white,

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),

                            title: Text(
                              'Cerrar sesión',

                              style: TextStyle(
                                color: const Color(0xFF0D5881),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            content: const Text(
                              '¿Seguro que quieres cerrar sesión?',
                            ),

                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },

                                child: const Text(
                                  'Cancelar',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),

                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context, true);
                                },

                                child: const Text(
                                  'Cerrar sesión',
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

                      if (confirmar != true) {
                        return;
                      }

                      context.read<AuthProvider>().restaurarSesion();

                      context.read<TrabajadorProvider>().clear();

                      Navigator.pushAndRemoveUntil(
                        context,

                        MaterialPageRoute(builder: (_) => const LoginScreen()),

                        (route) => false,
                      );
                    },

                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'logout',

                        child: Text(
                          'Cerrar sesión',

                          style: TextStyle(
                            color: const Color(0xFF0D5881),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // FICHAR
                Positioned(
                  left: 0,
                  right: 0,
                  top: 235.h,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FicharScreen()),
                      );
                    },
                    child: SizedBox(
                      height: 110.h,
                      child: Stack(
                        alignment: Alignment.center,

                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/boton1_trabajador.png',
                              fit: BoxFit.fill,
                            ),
                          ),

                          Positioned(
                            left: 35.w,
                            child: Image.asset(
                              'assets/images/iconpencil_trabajador.png',
                              width: 80.w,
                            ),
                          ),

                          Text(
                            'FICHAR',

                            style: TextStyle(
                              fontSize: 27.sp,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // SOLICITUD
                Positioned(
                  left: 0,
                  right: 0,
                  top: 390.h,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SolicitudScreen(),
                        ),
                      );
                    },
                    child: SizedBox(
                      height: 120.h,
                      child: Stack(
                        alignment: Alignment.center,

                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              'assets/images/boton2_trabajador.png',
                              fit: BoxFit.fill,
                            ),
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (solicitudesPendientes > 0)
                                Container(
                                  width: 24.w,
                                  height: 24.w,
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
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                              SizedBox(width: 10.w),

                              Text(
                                'SOLICITUD',
                                style: TextStyle(
                                  fontSize: 27.sp,
                                  letterSpacing: 3,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          Positioned(
                            right: 18.w,
                            top: 30.h,
                            child: Image.asset(
                              'assets/images/icondoc_trabajador.png',
                              width: 40.w,
                            ),
                          ),
                        ],
                      ),
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
}
