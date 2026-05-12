import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/trabajador_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => TrabajadorProvider(),
        ),
      ],

      child: ScreenUtilInit(
        designSize: const Size(390, 844),

        minTextAdapt: true,
        splitScreenMode: true,

        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,

            theme: ThemeData(
              fontFamily: 'WorkSans',
            ),

            home: child,
          );
        },

        child: const LoginScreen(),
      ),
    );
  }
}