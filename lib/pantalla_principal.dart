import 'package:flutter/material.dart';

import 'api.dart';
import 'datos.dart';
import 'pantalla_ajustes.dart';
import 'pantalla_buscar.dart';
import 'utiles.dart';
import 'vista_clima.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  final PageController _controlador = PageController();

  final Map<String, Map<String, dynamic>> _climas = {};
  final Map<String, Map<String, dynamic>> _aires = {};
  final Map<String, String> _errores = {};
  final List<String> _cargando = [];

  int _pagina = 0;
  bool _buscandoUbicacion = false;
  String _errorUbicacion = '';

  @override
  void initState() {
    super.initState();
    for (var ciudad in listaDeCiudades()) {
      cargarClima(ciudad);
    }
    if (usarUbicacion) buscarUbicacion();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> listaDeCiudades() {
    final lista = <Map<String, dynamic>>[];
    if (usarUbicacion && miUbicacion != null) lista.add(miUbicacion!);
    lista.addAll(ciudadesGuardadas);
    return lista;
  }

  Future<void> cargarClima(
    Map<String, dynamic> ciudad, {
    bool forzar = false,
  }) async {
    final clave = claveDeCiudad(ciudad);
    if (_cargando.contains(clave)) return;
    if (_climas[clave] != null && !forzar) return;

    setState(() {
      _cargando.add(clave);
      _errores.remove(clave);
    });

    try {
      final clima = await pedirClima(ciudad['latitud'], ciudad['longitud']);
      final aire = await pedirCalidadAire(
        ciudad['latitud'],
        ciudad['longitud'],
      );
      if (!mounted) return;
      setState(() {
        _climas[clave] = clima;
        if (aire != null) _aires[clave] = aire;
        _cargando.remove(clave);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errores[clave] = '$error';
        _cargando.remove(clave);
      });
    }
  }

  Future<void> buscarUbicacion() async {
    setState(() {
      _buscandoUbicacion = true;
      _errorUbicacion = '';
    });

    try {
      final ciudad = await buscarMiUbicacion();
      miUbicacion = ciudad;
      await guardarDatos();
      if (!mounted) return;
      setState(() => _buscandoUbicacion = false);
      await cargarClima(ciudad, forzar: true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _buscandoUbicacion = false;
        _errorUbicacion = '$error';
      });
    }
  }

  Future<void> abrirBuscador() async {
    final elegida = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaBuscar()),
    );
    if (!mounted) return;
    setState(() {});
    if (elegida == null) return;

    final ciudad = elegida as Map<String, dynamic>;
    await cargarClima(ciudad);
    if (!mounted) return;

    final lista = listaDeCiudades();
    for (var i = 0; i < lista.length; i++) {
      if (claveDeCiudad(lista[i]) == claveDeCiudad(ciudad)) {
        setState(() => _pagina = i);
        _controlador.jumpToPage(i);
      }
    }
  }

  Future<void> abrirAjustes() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaAjustes()),
    );
    if (!mounted) return;
    setState(() {});
    if (usarUbicacion && miUbicacion == null) buscarUbicacion();
  }

  int codigoActual() {
    final lista = listaDeCiudades();
    if (lista.isEmpty) return 2;
    final clima = _climas[claveDeCiudad(lista[_pagina.clamp(0, lista.length - 1)])];
    if (clima == null) return 2;
    return clima['current']['weather_code'];
  }

  bool esDiaActual() {
    final lista = listaDeCiudades();
    if (lista.isEmpty) return true;
    final clima = _climas[claveDeCiudad(lista[_pagina.clamp(0, lista.length - 1)])];
    if (clima == null) return true;
    return clima['current']['is_day'] == 1;
  }

  @override
  Widget build(BuildContext context) {
    final ciudades = listaDeCiudades();
    final colores = coloresDelCielo(codigoActual(), esDiaActual());

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colores[0], colores[1], colores[0]],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: esDiaActual() ? 0.30 : 0.14),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: DefaultTextStyle.merge(
                style: const TextStyle(color: Colors.white),
                child: IconTheme.merge(
                  data: const IconThemeData(color: Colors.white),
                  child: Column(
                    children: [
                      barraSuperior(ciudades.length),
                      Expanded(
                        child: ciudades.isEmpty
                            ? vistaSinCiudades()
                            : PageView.builder(
                                controller: _controlador,
                                itemCount: ciudades.length,
                                onPageChanged: (indice) {
                                  setState(() => _pagina = indice);
                                },
                                itemBuilder: (context, indice) {
                                  return paginaDeCiudad(ciudades[indice]);
                                },
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
    );
  }

  Widget barraSuperior(int cantidad) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: abrirBuscador,
            icon: const Icon(Icons.format_list_bulleted_rounded),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < cantidad; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _pagina ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withValues(
                        alpha: i == _pagina ? 1 : 0.45,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_buscandoUbicacion)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
          IconButton(
            onPressed: abrirAjustes,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
    );
  }

  Widget paginaDeCiudad(Map<String, dynamic> ciudad) {
    final clave = claveDeCiudad(ciudad);
    final clima = _climas[clave];

    if (clima == null && _errores[clave] != null) {
      return vistaDeError(_errores[clave]!, () {
        cargarClima(ciudad, forzar: true);
      });
    }

    if (clima == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return VistaClima(
      ciudad: ciudad,
      clima: clima,
      aire: _aires[clave],
      cargando: _cargando.contains(clave),
      alRefrescar: () => cargarClima(ciudad, forzar: true),
    );
  }

  Widget vistaDeError(String mensaje, VoidCallback alReintentar) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 70),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E3A5F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget vistaSinCiudades() {
    if (_buscandoUbicacion) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.my_location_rounded, size: 56),
            SizedBox(height: 16),
            Text('Buscando tu ubicación…', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.travel_explore_rounded, size: 76),
            const SizedBox(height: 18),
            const Text(
              'Agrega tu primera ciudad',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
            ),
            if (_errorUbicacion != '') ...[
              const SizedBox(height: 10),
              Text(
                _errorUbicacion,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: abrirBuscador,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Buscar ciudad'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1E3A5F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: buscarUbicacion,
              icon: const Icon(Icons.my_location_rounded),
              label: const Text('Usar mi ubicación'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
