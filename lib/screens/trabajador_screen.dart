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

  Future<void> _mostrarDialogoCambiarPassword(
    BuildContext screenContext,
  ) async {
    final actualController = TextEditingController();
    final nuevaController = TextEditingController();
    final repetirController = TextEditingController();

    bool cargando = false;
    bool ocultarActual = true;
    bool ocultarNueva = true;
    bool ocultarRepetir = true;

    await showDialog(
      context: screenContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> guardarPassword() async {
              final actual = actualController.text.trim();
              final nueva = nuevaController.text.trim();
              final repetir = repetirController.text.trim();

              if (actual.isEmpty || nueva.isEmpty || repetir.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Completa todos los campos'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (nueva != repetir) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Las nuevas contraseñas no coinciden'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              setStateDialog(() {
                cargando = true;
              });

              try {
                final authProvider = screenContext.read<AuthProvider>();
                final trabajadorProvider = screenContext
                    .read<TrabajadorProvider>();

                // Capturamos el navigator raíz ANTES de cualquier await
                final rootNav = Navigator.of(
                  screenContext,
                  rootNavigator: true,
                );

                await authProvider.cambiarPassword(
                  actual: actual,
                  nueva: nueva,
                );
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }

                await authProvider.logout();
                trabajadorProvider.clear();

                rootNav.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                if (!dialogContext.mounted) return;

                setStateDialog(() {
                  cargando = false;
                });

                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFF4F4F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              titlePadding: EdgeInsets.zero,
              contentPadding: const EdgeInsets.fromLTRB(26, 22, 26, 10),
              actionsPadding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              title: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 22,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D5881),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_reset_rounded,
                      color: Color(0xFFF7C81F),
                      size: 30,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cambiar contraseña',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: 410,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _passwordInput(
                      controller: actualController,
                      label: 'Contraseña actual',
                      obscure: ocultarActual,
                      onToggle: () {
                        setStateDialog(() {
                          ocultarActual = !ocultarActual;
                        });
                      },
                      onSubmitted: (_) => guardarPassword(),
                    ),
                    const SizedBox(height: 16),
                    _passwordInput(
                      controller: nuevaController,
                      label: 'Nueva contraseña',
                      obscure: ocultarNueva,
                      onToggle: () {
                        setStateDialog(() {
                          ocultarNueva = !ocultarNueva;
                        });
                      },
                      onSubmitted: (_) => guardarPassword(),
                    ),
                    const SizedBox(height: 16),
                    _passwordInput(
                      controller: repetirController,
                      label: 'Repetir nueva contraseña',
                      obscure: ocultarRepetir,
                      onToggle: () {
                        setStateDialog(() {
                          ocultarRepetir = !ocultarRepetir;
                        });
                      },
                      onSubmitted: (_) => guardarPassword(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: cargando
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Color(0xFF0D5881),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: cargando ? null : guardarPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF7C81F),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: cargando
                        ? const SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Guardar',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    actualController.dispose();
    nuevaController.dispose();
    repetirController.dispose();
  }

  Widget _passwordInput({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    void Function(String)? onSubmitted,
  }) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        onSubmitted: onSubmitted,
        style: const TextStyle(
          color: Color(0xFF222222),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Color(0xFF777777), fontSize: 14),
          prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF0D5881)),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF9E9E9E),
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),
        ),
      ),
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              color: Color(0xFF0D5881),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text('¿Seguro que quieres cerrar sesión?'),
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

    if (confirmar != true) return;

    await context.read<AuthProvider>().logout();
    context.read<TrabajadorProvider>().clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

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
                      if (value == 'change_password') {
                        await _mostrarDialogoCambiarPassword(context);
                        return;
                      }

                      if (value == 'logout') {
                        await _cerrarSesion(context);
                        return;
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'change_password',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lock_reset_rounded,
                              color: Color(0xFF0D5881),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              'Cambiar contraseña',
                              style: TextStyle(
                                color: const Color(0xFF0D5881),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            const Icon(Icons.logout, color: Color(0xFF0D5881)),
                            SizedBox(width: 10.w),
                            Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: const Color(0xFF0D5881),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

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
