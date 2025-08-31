// Manejo de ámbitos y variables para Chronicles

/// Representa un entorno de variables (scope)
class Environment {
  final Environment? parent;
  final Map<String, Object?> _values = {};

  Environment([this.parent]);

  /// Define una variable en el entorno actual
  void define(String name, Object? value) {
    _values[name] = value;
  }

  /// Asigna un valor a una variable existente
  void assign(String name, Object? value) {
    if (_values.containsKey(name)) {
      _values[name] = value;
    } else if (parent != null) {
      parent!.assign(name, value);
    } else {
      throw Exception('Variable "$name" no definida.');
    }
  }

  /// Obtiene el valor de una variable
  Object? get(String name) {
    if (_values.containsKey(name)) {
      return _values[name];
    } else if (parent != null) {
      return parent!.get(name);
    } else {
      throw Exception('Variable "$name" no definida.');
    }
  }
}