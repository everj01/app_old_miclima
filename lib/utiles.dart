import 'package:flutter/material.dart';

import 'datos.dart';

const List<String> nombresDias = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

String descripcionClima(int codigo) {
  if (codigo == 0) return 'Despejado';
  if (codigo == 1) return 'Mayormente despejado';
  if (codigo == 2) return 'Parcialmente nublado';
  if (codigo == 3) return 'Nublado';
  if (codigo == 45 || codigo == 48) return 'Niebla';
  if (codigo >= 51 && codigo <= 57) return 'Llovizna';
  if (codigo >= 61 && codigo <= 67) return 'Lluvia';
  if (codigo >= 71 && codigo <= 77) return 'Nieve';
  if (codigo >= 80 && codigo <= 82) return 'Chubascos';
  if (codigo == 85 || codigo == 86) return 'Chubascos de nieve';
  if (codigo >= 95) return 'Tormenta eléctrica';
  return 'Sin datos';
}

IconData iconoClima(int codigo, bool esDia) {
  if (codigo == 0 || codigo == 1) {
    return esDia ? Icons.wb_sunny_rounded : Icons.nightlight_round;
  }
  if (codigo == 2) {
    return esDia ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded;
  }
  if (codigo == 3) return Icons.cloud_rounded;
  if (codigo == 45 || codigo == 48) return Icons.foggy;
  if (codigo >= 51 && codigo <= 57) return Icons.grain_rounded;
  if (codigo >= 61 && codigo <= 67) return Icons.umbrella_rounded;
  if (codigo >= 71 && codigo <= 77) return Icons.ac_unit_rounded;
  if (codigo >= 80 && codigo <= 86) return Icons.water_drop_rounded;
  if (codigo >= 95) return Icons.thunderstorm_rounded;
  return Icons.cloud_rounded;
}

List<Color> coloresDelCielo(int codigo, bool esDia) {
  if (!esDia) {
    if (codigo >= 95) {
      return [const Color(0xFF130F2B), const Color(0xFF2C2A58)];
    }
    if (codigo >= 61) {
      return [const Color(0xFF0E1D24), const Color(0xFF24414F)];
    }
    if (codigo >= 1) {
      return [const Color(0xFF101A33), const Color(0xFF2A3A63)];
    }
    return [const Color(0xFF070B1C), const Color(0xFF1D2A5A)];
  }
  if (codigo >= 95) {
    return [const Color(0xFF2B3040), const Color(0xFF4A4463)];
  }
  if (codigo >= 61) {
    return [const Color(0xFF2E4D60), const Color(0xFF5E8398)];
  }
  if (codigo == 45 || codigo == 48) {
    return [const Color(0xFF657786), const Color(0xFF9BAAB6)];
  }
  if (codigo == 3) {
    return [const Color(0xFF4C6478), const Color(0xFF8099AC)];
  }
  if (codigo >= 1) {
    return [const Color(0xFF2A6BC4), const Color(0xFF6BA6E8)];
  }
  return [const Color(0xFF1668CE), const Color(0xFF63B8F5)];
}

double temperaturaConvertida(num grados) {
  if (usarCelsius) return grados.toDouble();
  return grados * 9 / 5 + 32;
}

String textoTemperatura(num grados) {
  return '${temperaturaConvertida(grados).round()}°';
}

String simboloTemperatura() {
  return usarCelsius ? '°C' : '°F';
}

String textoViento(num kilometrosPorHora) {
  if (usarMillas) {
    return '${(kilometrosPorHora * 0.621371).round()} mph';
  }
  return '${kilometrosPorHora.round()} km/h';
}

String direccionDelViento(num grados) {
  const puntos = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
  final indice = ((grados % 360) / 45).round() % 8;
  return puntos[indice];
}

String textoHora(String tiempo) {
  final fecha = DateTime.parse(tiempo);
  if (reloj24) return '${fecha.hour.toString().padLeft(2, '0')}:00';
  if (fecha.hour == 0) return '12 am';
  if (fecha.hour == 12) return '12 pm';
  if (fecha.hour < 12) return '${fecha.hour} am';
  return '${fecha.hour - 12} pm';
}

String textoReloj(String tiempo) {
  final fecha = DateTime.parse(tiempo);
  final minutos = fecha.minute.toString().padLeft(2, '0');
  if (reloj24) {
    return '${fecha.hour.toString().padLeft(2, '0')}:$minutos';
  }
  if (fecha.hour == 0) return '12:$minutos am';
  if (fecha.hour == 12) return '12:$minutos pm';
  if (fecha.hour < 12) return '${fecha.hour}:$minutos am';
  return '${fecha.hour - 12}:$minutos pm';
}

String textoDia(String fecha) {
  final dia = DateTime.parse(fecha);
  final hoy = DateTime.now();
  if (dia.day == hoy.day && dia.month == hoy.month) return 'Hoy';
  final manana = hoy.add(const Duration(days: 1));
  if (dia.day == manana.day && dia.month == manana.month) return 'Mañana';
  return nombresDias[dia.weekday - 1];
}

String nivelUv(num uv) {
  if (uv < 3) return 'Bajo';
  if (uv < 6) return 'Moderado';
  if (uv < 8) return 'Alto';
  if (uv < 11) return 'Muy alto';
  return 'Extremo';
}

String textoVisibilidad(num metros) {
  if (metros >= 1000) return '${(metros / 1000).round()} km';
  return '${metros.round()} m';
}

String textoCalidadAire(num indice) {
  if (indice <= 50) return 'Buena';
  if (indice <= 100) return 'Moderada';
  if (indice <= 150) return 'Dañina para sensibles';
  if (indice <= 200) return 'Dañina';
  if (indice <= 300) return 'Muy dañina';
  return 'Peligrosa';
}

String consejoCalidadAire(num indice) {
  if (indice <= 50) return 'Aire limpio, buen momento para salir.';
  if (indice <= 100) return 'Aceptable, las personas sensibles deben cuidarse.';
  if (indice <= 150) return 'Reduce el ejercicio al aire libre.';
  if (indice <= 200) return 'Evita actividades largas en la calle.';
  return 'Mejor quédate en casa si puedes.';
}

Color colorCalidadAire(num indice) {
  if (indice <= 50) return const Color(0xFF4ADE80);
  if (indice <= 100) return const Color(0xFFFACC15);
  if (indice <= 150) return const Color(0xFFFB923C);
  if (indice <= 200) return const Color(0xFFF87171);
  if (indice <= 300) return const Color(0xFFC084FC);
  return const Color(0xFFE11D48);
}

Color colorTemperatura(num grados) {
  if (grados <= 0) return const Color(0xFF93C5FD);
  if (grados <= 10) return const Color(0xFF67E8F9);
  if (grados <= 16) return const Color(0xFF6EE7B7);
  if (grados <= 22) return const Color(0xFFFDE047);
  if (grados <= 28) return const Color(0xFFFDBA74);
  if (grados <= 34) return const Color(0xFFFB923C);
  return const Color(0xFFF87171);
}

String resumenDelDia(Map<String, dynamic> clima) {
  final lluvia = clima['daily']['precipitation_probability_max'][0] ?? 0;
  final maxima = clima['daily']['temperature_2m_max'][0];
  final minima = clima['daily']['temperature_2m_min'][0];
  final uv = clima['daily']['uv_index_max'][0] ?? 0;

  if (lluvia >= 60) {
    return 'Alta probabilidad de lluvia ($lluvia%), lleva paraguas.';
  }
  if (uv >= 8) {
    return 'Índice UV ${nivelUv(uv).toLowerCase()}, usa bloqueador solar.';
  }
  if (maxima - minima >= 12) {
    return 'El día cambia mucho: de ${textoTemperatura(minima)} a ${textoTemperatura(maxima)}.';
  }
  if (maxima <= 12) {
    return 'Día frío, abrígate bien antes de salir.';
  }
  return 'Día tranquilo, máxima de ${textoTemperatura(maxima)}.';
}

int indiceHoraActual(Map<String, dynamic> clima) {
  final ahora = DateTime.parse(clima['current']['time']);
  final horas = clima['hourly']['time'] as List;
  for (var i = 0; i < horas.length; i++) {
    final hora = DateTime.parse(horas[i]);
    if (hora.day == ahora.day && hora.hour == ahora.hour) return i;
  }
  return 0;
}
