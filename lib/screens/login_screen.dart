import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/trabajador_provider.dart';

import 'trabajador_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();

  final _contrasenaController = TextEditingController();

  bool _obscurePassword = true;

  static const Color amarillo = Color(0xFFFAC02E);

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/fondo_login.png',
              fit: BoxFit.cover,
            ),
          ),

          // USUARIO
          Positioned(
            left: 60.w,
            top: 220.h,

            child: _buildLabel('Usuario', 'assets/images/user_login.png'),
          ),

          Positioned(
            left: 42.w,
            right: 42.w,
            top: 250.h,

            child: _buildCaja(controller: _usuarioController, obscure: false),
          ),

          // CONTRASEÑA
          Positioned(
            left: 60.w,
            top: 380.h,

            child: _buildLabel('Contraseña', 'assets/images/candado_login.png'),
          ),

          Positioned(
            left: 42.w,
            right: 42.w,
            top: 410.h,

            child: _buildCaja(
              controller: _contrasenaController,

              obscure: _obscurePassword,

              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,

                  size: 20.sp,
                  color: Colors.grey,
                ),

                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
          ),

          // BOTÓN
          Positioned(
            left: 30.w,
            right: 30.w,
            top: 540.h,

            child: GestureDetector(
              onTap: auth.cargando ? null : _onLogin,

              child: auth.cargando
                  ? SizedBox(
                      height: 95.h,

                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : Image.asset(
                      'assets/images/boton_login.png',

                      height: 95.h,

                      fit: BoxFit.contain,
                    ),
            ),
          ),

          // RECUPERAR
          Positioned(
            left: 0,
            right: 0,
            top: 630.h,

            child: GestureDetector(
              onTap: _onForgotPassword,

              child: RichText(
                textAlign: TextAlign.center,

                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15.sp,

                    color: const Color(0xFF888888),
                  ),

                  children: const [
                    TextSpan(text: '¿Olvidaste tu contraseña?'),

                    TextSpan(
                      text: '*',

                      style: TextStyle(color: amarillo),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String texto, String icono) {
    return Row(
      children: [
        Image.asset(icono, width: 26.w, height: 26.w, fit: BoxFit.contain),

        SizedBox(width: 8.w),

        Text(
          texto,

          style: TextStyle(
            color: Colors.white,

            fontSize: 16.sp,

            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCaja({
    required TextEditingController controller,
    required bool obscure,
    Widget? suffix,
  }) {
    const escala = 1.95;

    final anchoCaja = 300.w * escala;
    final altoCaja = 40.h * escala;

    return SizedBox(
      width: anchoCaja,
      height: altoCaja,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscure,

          cursorColor: Colors.black,

          style: TextStyle(fontSize: 16.sp, color: const Color(0xFF333333)),

          textAlignVertical: TextAlignVertical.center,

          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,

            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.r),
              borderSide: BorderSide.none,
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(32.r),
              borderSide: BorderSide.none,
            ),

            suffixIcon: suffix,
          ),
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    if (_usuarioController.text.trim().isEmpty) {
      _mostrarError('Introduce usuario');

      return;
    }

    if (_contrasenaController.text.trim().isEmpty) {
      _mostrarError('Introduce contraseña');

      return;
    }

    final auth = context.read<AuthProvider>();

    final trabajador = context.read<TrabajadorProvider>();

    try {
      await auth.login(
        _usuarioController.text.trim(),

        _contrasenaController.text.trim(),
      );

      await trabajador.cargarMiArea(
        apikey: auth.apikey,

        idTrabajador: auth.idTrabajador!,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,

        MaterialPageRoute(builder: (_) => const TrabajadorScreen()),
      );
    } catch (e) {
      _mostrarError(e.toString());
    }
  }

  void _mostrarError(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _onForgotPassword() {}
}
