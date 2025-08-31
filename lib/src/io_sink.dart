// Interfaz para captura de salida en pruebas de Chronicles

/// Permite redirigir la salida estándar para pruebas
class IOSinkCapture {
  final List<String> _lines = [];
  void write(String line) => _lines.add(line);
  void clear() => _lines.clear();
  List<String> get lines => List.unmodifiable(_lines);
}