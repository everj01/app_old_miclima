import 'package:flutter/material.dart';

import 'api.dart';
import 'datos.dart';

class PantallaBuscar extends StatefulWidget {
  const PantallaBuscar({super.key});

  @override
  State<PantallaBuscar> createState() => _PantallaBuscarState();
}

class _PantallaBuscarState extends State<PantallaBuscar> {
  final TextEditingController _texto = TextEditingController();

  List<Map<String, dynamic>> _resultados = [];
  bool _buscando = false;
  String _error = '';

  final List<String> _sugerencias = [
    'Lima',
    'Cusco',
    'Arequipa',
    'Madrid',
    'Buenos Aires',
    'Ciudad de México',
    'Bogotá',
    'Tokio',
  ];

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> buscar(String palabra) async {
    if (palabra.trim().length < 2) return;
    _texto.text = palabra;

    setState(() {
      _buscando = true;
      _error = '';
      _resultados = [];
    });

    try {
      final encontradas = await buscarCiudades(palabra.trim());
      if (!mounted) return;
      setState(() {
        _resultados = encontradas;
        _buscando = false;
        if (encontradas.isEmpty) _error = 'No encontré ninguna ciudad así.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _buscando = false;
        _error = '$error';
      });
    }
  }

  Future<void> agregarCiudad(Map<String, dynamic> ciudad) async {
    if (!yaEstaGuardada(ciudad)) {
      ciudadesGuardadas.add(ciudad);
      await guardarDatos();
    }
    if (!mounted) return;
    Navigator.pop(context, ciudad);
  }

  Future<void> borrarCiudad(Map<String, dynamic> ciudad) async {
    ciudadesGuardadas.removeWhere(
      (guardada) => claveDeCiudad(guardada) == claveDeCiudad(ciudad),
    );
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
                      'Mis ciudades',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _texto,
                  textInputAction: TextInputAction.search,
                  onSubmitted: buscar,
                  decoration: InputDecoration(
                    hintText: 'Buscar una ciudad…',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.08),
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => buscar(_texto.text),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(child: cuerpo()),
            ],
          ),
        ),
      ),
    );
  }

  Widget cuerpo() {
    if (_buscando) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
      children: [
        if (_error != '')
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _error,
              style: const TextStyle(color: Color(0xFFFFB4A2)),
            ),
          ),
        if (_resultados.isNotEmpty) ...[
          const Text('Resultados', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          for (var ciudad in _resultados)
            filaDeCiudad(ciudad, yaEstaGuardada(ciudad)),
        ],
        if (_resultados.isEmpty) ...[
          const Text('Ciudades populares', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var sugerencia in _sugerencias)
                ActionChip(
                  label: Text(sugerencia),
                  onPressed: () => buscar(sugerencia),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 26),
          if (ciudadesGuardadas.isNotEmpty) ...[
            const Text('Guardadas', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            for (var ciudad in ciudadesGuardadas) filaDeCiudad(ciudad, true),
          ],
        ],
      ],
    );
  }

  Widget filaDeCiudad(Map<String, dynamic> ciudad, bool guardada) {
    final bandera = banderaDePais(ciudad['codigoPais'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.07),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: ListTile(
        onTap: () => agregarCiudad(ciudad),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Text(bandera, style: const TextStyle(fontSize: 22)),
        title: Text(ciudad['nombre']),
        subtitle: Text(
          ciudad['region'] != ''
              ? '${ciudad['region']}, ${ciudad['pais']}'
              : ciudad['pais'],
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
        trailing: guardada
            ? IconButton(
                onPressed: () => borrarCiudad(ciudad),
                icon: const Icon(Icons.delete_outline_rounded),
              )
            : const Icon(Icons.add_rounded),
      ),
    );
  }
}
