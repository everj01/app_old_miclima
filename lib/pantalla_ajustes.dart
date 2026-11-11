import 'package:flutter/material.dart';

import 'datos.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  Future<void> guardarYRefrescar() async {
    await guardarDatos();
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF101A33), Color(0xFF0B1220)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const Text(
                      'Ajustes',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                  children: [
                    bloque('Unidades', [
                      opcionDoble(
                        'Temperatura',
                        Icons.thermostat_rounded,
                        '°C',
                        '°F',
                        usarCelsius,
                        (valor) {
                          usarCelsius = valor;
                          guardarYRefrescar();
                        },
                      ),
                      opcionDoble(
                        'Viento',
                        Icons.air_rounded,
                        'km/h',
                        'mph',
                        !usarMillas,
                        (valor) {
                          usarMillas = !valor;
                          guardarYRefrescar();
                        },
                      ),
                      opcionDoble(
                        'Hora',
                        Icons.schedule_rounded,
                        '24 h',
                        '12 h',
                        reloj24,
                        (valor) {
                          reloj24 = valor;
                          guardarYRefrescar();
                        },
                      ),
                    ]),
                    const SizedBox(height: 20),
                    bloque('Ubicación', [
                      SwitchListTile(
                        value: usarUbicacion,
                        onChanged: (valor) {
                          usarUbicacion = valor;
                          if (!valor) miUbicacion = null;
                          guardarYRefrescar();
                        },
                        title: const Text('Usar mi ubicación actual'),
                        subtitle: Text(
                          'Muestra primero el clima de donde estás',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                        secondary: const Icon(Icons.my_location_rounded),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    bloque('Acerca de', [
                      const ListTile(
                        leading: Icon(Icons.cloud_rounded),
                        title: Text('Mi Clima 1.0'),
                        subtitle: Text('Datos del clima por Open-Meteo'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.code_rounded),
                        title: const Text('Hecho con Flutter'),
                        subtitle: Text(
                          '${ciudadesGuardadas.length} ciudades guardadas',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget bloque(String titulo, List<Widget> hijos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 8),
          child: Text(
            titulo.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.07),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(children: hijos),
        ),
      ],
    );
  }

  Widget opcionDoble(
    String titulo,
    IconData icono,
    String primera,
    String segunda,
    bool primeraActiva,
    Function(bool) alCambiar,
  ) {
    return ListTile(
      leading: Icon(icono),
      title: Text(titulo),
      trailing: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Row(
          children: [
            botonOpcion(primera, primeraActiva, () => alCambiar(true)),
            botonOpcion(segunda, !primeraActiva, () => alCambiar(false)),
          ],
        ),
      ),
    );
  }

  Widget botonOpcion(String texto, bool activo, VoidCallback alTocar) {
    return GestureDetector(
      onTap: alTocar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: activo ? Colors.white : Colors.transparent,
        ),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: activo
                ? const Color(0xFF1E3A5F)
                : Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
