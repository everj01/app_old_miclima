import 'package:flutter/material.dart';

class Tarjeta extends StatelessWidget {
  const Tarjeta({
    super.key,
    required this.contenido,
    this.titulo = '',
    this.icono,
    this.relleno = const EdgeInsets.all(18),
  });

  final Widget contenido;
  final String titulo;
  final IconData? icono;
  final EdgeInsets relleno;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: relleno,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.06),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (titulo != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Icon(icono, size: 17, color: Colors.white.withValues(alpha: 0.85)),
                  const SizedBox(width: 8),
                  Text(
                    titulo.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          contenido,
        ],
      ),
    );
  }
}

class EtiquetaDato extends StatelessWidget {
  const EtiquetaDato({
    super.key,
    required this.icono,
    required this.titulo,
    required this.valor,
    this.nota = '',
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final String nota;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icono, size: 16, color: Colors.white.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
          Text(
            valor,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
          ),
          Text(
            nota,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}
