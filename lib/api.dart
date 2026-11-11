import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'datos.dart';

Future<Map<String, dynamic>> pedirClima(double latitud, double longitud) async {
  final direccion = 'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitud'
      '&longitude=$longitud'
      '&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,'
      'precipitation,weather_code,cloud_cover,pressure_msl,wind_speed_10m,'
      'wind_direction_10m,wind_gusts_10m,dew_point_2m'
      '&hourly=temperature_2m,weather_code,precipitation_probability,is_day,'
      'uv_index,visibility,relative_humidity_2m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,'
      'uv_index_max,precipitation_sum,precipitation_probability_max,wind_speed_10m_max'
      '&timezone=auto&forecast_days=7';

  final respuesta = await http
      .get(Uri.parse(direccion))
      .timeout(const Duration(seconds: 15));

  if (respuesta.statusCode != 200) {
    throw 'El servicio del clima respondió con error ${respuesta.statusCode}.';
  }

  return jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;
}

Future<Map<String, dynamic>?> pedirCalidadAire(
  double latitud,
  double longitud,
) async {
  try {
    final direccion = 'https://air-quality-api.open-meteo.com/v1/air-quality'
        '?latitude=$latitud'
        '&longitude=$longitud'
        '&current=us_aqi,pm10,pm2_5,ozone,nitrogen_dioxide'
        '&timezone=auto';

    final respuesta = await http
        .get(Uri.parse(direccion))
        .timeout(const Duration(seconds: 15));

    if (respuesta.statusCode != 200) return null;

    final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (json['current'] == null) return null;
    return Map<String, dynamic>.from(json['current']);
  } catch (error) {
    return null;
  }
}

Future<List<Map<String, dynamic>>> buscarCiudades(String texto) async {
  final direccion = 'https://geocoding-api.open-meteo.com/v1/search'
      '?name=${Uri.encodeComponent(texto)}&count=12&language=es&format=json';

  final respuesta = await http
      .get(Uri.parse(direccion))
      .timeout(const Duration(seconds: 15));

  if (respuesta.statusCode != 200) {
    throw 'No se pudo buscar la ciudad (error ${respuesta.statusCode}).';
  }

  final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
  final resultados = json['results'] as List?;
  if (resultados == null) return [];

  final ciudades = <Map<String, dynamic>>[];
  for (var item in resultados) {
    ciudades.add(
      crearCiudad(
        item['name'] ?? 'Sin nombre',
        item['admin1'] ?? '',
        item['country'] ?? '',
        item['country_code'] ?? '',
        (item['latitude'] as num).toDouble(),
        (item['longitude'] as num).toDouble(),
      ),
    );
  }
  return ciudades;
}

Future<Map<String, dynamic>> buscarMiUbicacion() async {
  final gpsActivo = await Geolocator.isLocationServiceEnabled();
  if (!gpsActivo) {
    throw 'Activa el GPS para ver el clima de tu ubicación.';
  }

  var permiso = await Geolocator.checkPermission();
  if (permiso == LocationPermission.denied) {
    permiso = await Geolocator.requestPermission();
  }
  if (permiso == LocationPermission.denied) {
    throw 'Necesito el permiso de ubicación para mostrarte tu clima.';
  }
  if (permiso == LocationPermission.deniedForever) {
    throw 'El permiso de ubicación está bloqueado, actívalo en los ajustes del teléfono.';
  }

  final posicion = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 20),
    ),
  );

  return await nombreDeLaUbicacion(posicion.latitude, posicion.longitude);
}

Future<Map<String, dynamic>> nombreDeLaUbicacion(
  double latitud,
  double longitud,
) async {
  try {
    final direccion = 'https://api.bigdatacloud.net/data/reverse-geocode-client'
        '?latitude=$latitud&longitude=$longitud&localityLanguage=es';

    final respuesta = await http
        .get(Uri.parse(direccion))
        .timeout(const Duration(seconds: 15));

    final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    var nombre = json['city'];
    if (nombre == null || nombre == '') nombre = json['locality'];
    if (nombre == null || nombre == '') nombre = 'Mi ubicación';

    return crearCiudad(
      nombre,
      json['principalSubdivision'] ?? '',
      json['countryName'] ?? '',
      json['countryCode'] ?? '',
      latitud,
      longitud,
    );
  } catch (error) {
    return crearCiudad('Mi ubicación', '', '', '', latitud, longitud);
  }
}
