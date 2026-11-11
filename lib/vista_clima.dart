import 'package:flutter/material.dart';

import 'datos.dart';
import 'tarjeta.dart';
import 'utiles.dart';

class VistaClima extends StatelessWidget {
  const VistaClima({
    super.key,
    required this.ciudad,
    required this.clima,
    required this.aire,
    required this.cargando,
    required this.alRefrescar,
  });

  final Map<String, dynamic> ciudad;
  final Map<String, dynamic> clima;
  final Map<String, dynamic>? aire;
  final bool cargando;
  final Future<void> Function() alRefrescar;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.white,
      backgroundColor: Colors.black.withValues(alpha: 0.3),
      onRefresh: alRefrescar,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 36),
        children: [
          cabecera(),
          const SizedBox(height: 26),
          tarjetaResumen(),
          const SizedBox(height: 14),
          tarjetaHoras(),
          const SizedBox(height: 14),
          tarjetaSemana(),
          const SizedBox(height: 14),
          if (aire != null) tarjetaAire(),
          if (aire != null) const SizedBox(height: 14),
          SizedBox(
            height: 210,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tarjetaViento()),
                const SizedBox(width: 14),
                Expanded(child: tarjetaSol()),
              ],
            ),
          ),
          const SizedBox(height: 14),
          tarjetaDetalles(),
          const SizedBox(height: 18),
          Text(
            'Datos de Open-Meteo · ${textoReloj(clima['current']['time'])}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget cabecera() {
    final actual = clima['current'];
    final diario = clima['daily'];
    final bandera = banderaDePais(ciudad['codigoPais'] ?? '');

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (miUbicacion != null &&
                claveDeCiudad(ciudad) == claveDeCiudad(miUbicacion!))
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.near_me_rounded, size: 16),
              ),
            Text(
              '$bandera ${ciudad['nombre']}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        if (ciudad['pais'] != '')
          Text(
            ciudad['region'] != ''
                ? '${ciudad['region']}, ${ciudad['pais']}'
                : ciudad['pais'],
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textoTemperatura(actual['temperature_2m']),
              style: const TextStyle(
                fontSize: 104,
                fontWeight: FontWeight.w200,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14, left: 4),
              child: Text(
                simboloTemperatura(),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconoClima(actual['weather_code'], actual['is_day'] == 1),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              descripcionClima(actual['weather_code']),
              style: const TextStyle(fontSize: 17),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Máx ${textoTemperatura(diario['temperature_2m_max'][0])}   '
          'Mín ${textoTemperatura(diario['temperature_2m_min'][0])}   '
          'Sensación ${textoTemperatura(actual['apparent_temperature'])}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        if (cargando)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Actualizando…',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }

  Widget tarjetaResumen() {
    return Tarjeta(
      relleno: const EdgeInsets.all(16),
      contenido: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
            child: const Icon(Icons.auto_awesome_rounded, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              resumenDelDia(clima),
              style: const TextStyle(fontSize: 14.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaHoras() {
    final horas = clima['hourly'];
    final inicio = indiceHoraActual(clima);
    final total = (horas['time'] as List).length;
    final fin = inicio + 24 > total ? total : inicio + 24;

    return Tarjeta(
      titulo: 'Próximas 24 horas',
      icono: Icons.schedule_rounded,
      relleno: const EdgeInsets.fromLTRB(14, 16, 6, 12),
      contenido: SizedBox(
        height: 152,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: fin - inicio,
          itemBuilder: (context, posicion) {
            final i = inicio + posicion;
            final temperatura = horas['temperature_2m'][i];
            final probabilidad = horas['precipitation_probability'][i] ?? 0;

            return Container(
              width: 62,
              margin: const EdgeInsets.only(right: 8),
              child: Column(
                children: [
                  Text(
                    posicion == 0 ? 'Ahora' : textoHora(horas['time'][i]),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    iconoClima(horas['weather_code'][i], horas['is_day'][i] == 1),
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    probabilidad > 10 ? '$probabilidad%' : '',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF93D6FF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 5,
                    height: 34,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colorTemperatura(temperatura).withValues(alpha: 0.35),
                          colorTemperatura(temperatura),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    textoTemperatura(temperatura),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget tarjetaSemana() {
    final diario = clima['daily'];
    final dias = (diario['time'] as List).length;

    var minimaSemana = diario['temperature_2m_min'][0] as num;
    var maximaSemana = diario['temperature_2m_max'][0] as num;
    for (var i = 0; i < dias; i++) {
      if (diario['temperature_2m_min'][i] < minimaSemana) {
        minimaSemana = diario['temperature_2m_min'][i];
      }
      if (diario['temperature_2m_max'][i] > maximaSemana) {
        maximaSemana = diario['temperature_2m_max'][i];
      }
    }
    final rango = maximaSemana - minimaSemana == 0
        ? 1
        : maximaSemana - minimaSemana;

    return Tarjeta(
      titulo: 'Pronóstico de 7 días',
      icono: Icons.calendar_today_rounded,
      contenido: Column(
        children: [
          for (var i = 0; i < dias; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    child: Text(
                      textoDia(diario['time'][i]),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Icon(iconoClima(diario['weather_code'][i], true), size: 19),
                  SizedBox(
                    width: 42,
                    child: Text(
                      (diario['precipitation_probability_max'][i] ?? 0) > 10
                          ? '${diario['precipitation_probability_max'][i]}%'
                          : '',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF93D6FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 34,
                    child: Text(
                      textoTemperatura(diario['temperature_2m_min'][i]),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: barraDeTemperatura(i, minimaSemana, rango)),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 34,
                    child: Text(
                      textoTemperatura(diario['temperature_2m_max'][i]),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
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

  Widget barraDeTemperatura(int indice, num minimaSemana, num rango) {
    final diario = clima['daily'];
    final minima = diario['temperature_2m_min'][indice] as num;
    final maxima = diario['temperature_2m_max'][indice] as num;

    final espacioIzquierda =
        (((minima - minimaSemana) / rango) * 100).round().clamp(1, 90).toInt();
    final anchoBarra =
        (((maxima - minima) / rango) * 100).round().clamp(8, 99).toInt();
    final espacioDerecha =
        (100 - espacioIzquierda - anchoBarra).clamp(1, 99).toInt();

    return Container(
      height: 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white.withValues(alpha: 0.14),
      ),
      child: Row(
        children: [
          Expanded(flex: espacioIzquierda, child: const SizedBox()),
          Expanded(
            flex: anchoBarra,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  colors: [colorTemperatura(minima), colorTemperatura(maxima)],
                ),
              ),
            ),
          ),
          Expanded(flex: espacioDerecha, child: const SizedBox()),
        ],
      ),
    );
  }

  Widget tarjetaAire() {
    final num indice = aire!['us_aqi'] ?? 0;
    final color = colorCalidadAire(indice);
    final int ancho = (indice / 300 * 100).round().clamp(2, 100);

    return Tarjeta(
      titulo: 'Calidad del aire',
      icono: Icons.air_rounded,
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${indice.round()}',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                  color: color,
                  height: 1,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  textoCalidadAire(indice),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withValues(alpha: 0.14),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: ancho,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: color,
                    ),
                  ),
                ),
                Expanded(flex: 100 - ancho, child: const SizedBox()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            consejoCalidadAire(indice),
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              contaminante('PM2.5', aire!['pm2_5']),
              contaminante('PM10', aire!['pm10']),
              contaminante('O₃', aire!['ozone']),
              contaminante('NO₂', aire!['nitrogen_dioxide']),
            ],
          ),
        ],
      ),
    );
  }

  Widget contaminante(String nombre, dynamic valor) {
    return Column(
      children: [
        Text(
          valor == null ? '—' : '${(valor as num).round()}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          nombre,
          style: TextStyle(
            fontSize: 11.5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget tarjetaViento() {
    final actual = clima['current'];
    final grados = actual['wind_direction_10m'] as num;

    return Tarjeta(
      titulo: 'Viento',
      icono: Icons.air_rounded,
      relleno: const EdgeInsets.all(16),
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 2,
                ),
              ),
              child: Transform.rotate(
                angle: grados * 3.1416 / 180,
                child: const Icon(Icons.navigation_rounded, size: 30),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            textoViento(actual['wind_speed_10m']),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Text(
            'Dirección ${direccionDelViento(grados)} · ráfagas ${textoViento(actual['wind_gusts_10m'])}',
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaSol() {
    final diario = clima['daily'];
    final amanecer = DateTime.parse(diario['sunrise'][0]);
    final atardecer = DateTime.parse(diario['sunset'][0]);
    final ahora = DateTime.parse(clima['current']['time']);

    final totalMinutos = atardecer.difference(amanecer).inMinutes;
    final pasados = ahora.difference(amanecer).inMinutes;
    final avance = totalMinutos <= 0
        ? 2
        : (pasados / totalMinutos * 100).round().clamp(2, 100).toInt();

    return Tarjeta(
      titulo: 'Sol',
      icono: Icons.wb_twilight_rounded,
      relleno: const EdgeInsets.all(16),
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_rounded, size: 18),
              const SizedBox(width: 8),
              Text(
                textoReloj(diario['sunrise'][0]),
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white.withValues(alpha: 0.14),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: avance,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFF8A65)],
                      ),
                    ),
                  ),
                ),
                Expanded(flex: 100 - avance, child: const SizedBox()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.nightlight_round, size: 18),
              const SizedBox(width: 8),
              Text(
                textoReloj(diario['sunset'][0]),
                style: const TextStyle(fontSize: 17),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${totalMinutos ~/ 60} h ${totalMinutos % 60} min de luz',
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget tarjetaDetalles() {
    final actual = clima['current'];
    final horas = clima['hourly'];
    final i = indiceHoraActual(clima);
    final uv = horas['uv_index'][i] ?? 0;
    final visibilidad = horas['visibility'][i] ?? 0;

    return Column(
      children: [
        filaDeDetalles(
          EtiquetaDato(
            icono: Icons.water_drop_outlined,
            titulo: 'Humedad',
            valor: '${actual['relative_humidity_2m'].round()}%',
            nota: 'Rocío a ${textoTemperatura(actual['dew_point_2m'])}',
          ),
          EtiquetaDato(
            icono: Icons.wb_sunny_outlined,
            titulo: 'Índice UV',
            valor: '${(uv as num).round()}',
            nota: nivelUv(uv),
          ),
        ),
        const SizedBox(height: 14),
        filaDeDetalles(
          EtiquetaDato(
            icono: Icons.speed_rounded,
            titulo: 'Presión',
            valor: '${actual['pressure_msl'].round()}',
            nota: 'hPa a nivel del mar',
          ),
          EtiquetaDato(
            icono: Icons.visibility_outlined,
            titulo: 'Visibilidad',
            valor: textoVisibilidad(visibilidad),
            nota: visibilidad >= 10000
                ? 'Visibilidad excelente'
                : 'Visibilidad reducida',
          ),
        ),
        const SizedBox(height: 14),
        filaDeDetalles(
          EtiquetaDato(
            icono: Icons.cloud_outlined,
            titulo: 'Nubosidad',
            valor: '${actual['cloud_cover'].round()}%',
            nota: descripcionClima(actual['weather_code']),
          ),
          EtiquetaDato(
            icono: Icons.umbrella_outlined,
            titulo: 'Lluvia hoy',
            valor: '${clima['daily']['precipitation_sum'][0] ?? 0} mm',
            nota:
                '${clima['daily']['precipitation_probability_max'][0] ?? 0}% de probabilidad',
          ),
        ),
      ],
    );
  }

  Widget filaDeDetalles(Widget izquierda, Widget derecha) {
    return SizedBox(
      height: 130,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: izquierda),
          const SizedBox(width: 14),
          Expanded(child: derecha),
        ],
      ),
    );
  }
}
