// Interfaz para captura de salida en pruebas de Chronicles

/// Permite redirigir la salida estándar para pruebas
class IOSinkCapture { // Inicio clase
  final List<String> _lines = []; // Lista interna de líneas
  void write(String line) => _lines.add(line); // Agrega una línea
  void clear() => _lines.clear(); // Limpia todas las líneas
  List<String> get lines => List.unmodifiable(_lines); // Exposición inmutable
}