import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'datos.dart';
import 'pantalla_principal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarDatosGuardados();
  runApp(const MiClimaApp());
}

class MiClimaApp extends StatelessWidget {
  const MiClimaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Clima',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B1220),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const PantallaPrincipal(),
    );
  }
}
