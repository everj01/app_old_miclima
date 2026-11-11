import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, dynamic>> ciudadesGuardadas = [];
Map<String, dynamic>? miUbicacion;
bool usarUbicacion = true;
bool usarCelsius = true;
bool usarMillas = false;
bool reloj24 = true;

Map<String, dynamic> crearCiudad(
  String nombre,
  String region,
  String pais,
  String codigoPais,
  double latitud,
  double longitud,
) {
  return {
    'nombre': nombre,
    'region': region,
    'pais': pais,
    'codigoPais': codigoPais,
    'latitud': latitud,
    'longitud': longitud,
  };
}

String claveDeCiudad(Map<String, dynamic> ciudad) {
  final latitud = ciudad['latitud'].toStringAsFixed(2);
  final longitud = ciudad['longitud'].toStringAsFixed(2);
  return '$latitud,$longitud';
}

String banderaDePais(String codigoPais) {
  if (codigoPais.length != 2) return '';
  final letras = codigoPais.toUpperCase().codeUnits;
  if (letras[0] < 65 || letras[0] > 90) return '';
  if (letras[1] < 65 || letras[1] > 90) return '';
  return String.fromCharCode(0x1F1E6 + letras[0] - 65) +
      String.fromCharCode(0x1F1E6 + letras[1] - 65);
}

bool yaEstaGuardada(Map<String, dynamic> ciudad) {
  for (var guardada in ciudadesGuardadas) {
    if (claveDeCiudad(guardada) == claveDeCiudad(ciudad)) return true;
  }
  return false;
}

Future<void> cargarDatosGuardados() async {
  final memoria = await SharedPreferences.getInstance();

  usarUbicacion = memoria.getBool('usarUbicacion') ?? true;
  usarCelsius = memoria.getBool('usarCelsius') ?? true;
  usarMillas = memoria.getBool('usarMillas') ?? false;
  reloj24 = memoria.getBool('reloj24') ?? true;

  final textoCiudades = memoria.getString('ciudades');
  if (textoCiudades != null) {
    ciudadesGuardadas = [];
    final lista = jsonDecode(textoCiudades) as List;
    for (var item in lista) {
      ciudadesGuardadas.add(Map<String, dynamic>.from(item));
    }
  }

  final textoUbicacion = memoria.getString('miUbicacion');
  if (textoUbicacion != null) {
    miUbicacion = Map<String, dynamic>.from(jsonDecode(textoUbicacion));
  }

  if (ciudadesGuardadas.isEmpty && !usarUbicacion) {
    ciudadesGuardadas.add(
      crearCiudad('Lima', 'Lima', 'Perú', 'PE', -12.0432, -77.0282),
    );
  }
}

Future<void> guardarDatos() async {
  final memoria = await SharedPreferences.getInstance();
  await memoria.setBool('usarUbicacion', usarUbicacion);
  await memoria.setBool('usarCelsius', usarCelsius);
  await memoria.setBool('usarMillas', usarMillas);
  await memoria.setBool('reloj24', reloj24);
  await memoria.setString('ciudades', jsonEncode(ciudadesGuardadas));
  if (miUbicacion != null) {
    await memoria.setString('miUbicacion', jsonEncode(miUbicacion));
  }
}
