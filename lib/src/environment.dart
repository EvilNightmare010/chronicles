// Manejo de ámbitos y variables para Chronicles
import 'value.dart'; // Importa tipos de valores para validación de tipos

/// Representa un entorno de variables (scope) // Clase para scopes anidados
class Environment { // Inicio clase Environment
  final Environment? parent; // Referencia al entorno padre (o null)
  final Map<String, Object?> _values = {}; // Mapa interno de nombres a valores
  final Map<String, String?> _types = {}; // Mapa de tipos declarados

  Environment([this.parent]); // Constructor con padre opcional

  /// Define una variable en el entorno actual // Documenta define
  void define(String name, Object? value, {String? type}) { // Método define con tipo opcional
    _values[name] = value; // Inserta valor
    if (type != null) _types[name] = type; // Registra tipo si provisto
  }

  /// Asigna un valor a una variable existente // Documenta assign
  void assign(String name, Object? value) { // Método assign
    if (_values.containsKey(name)) { // Si existe localmente
      final declared = _types[name]; // Tipo declarado
      if (declared != null && !_checkType(declared, value)) { // Incompatibilidad
        throw Exception('Tipo incompatible para "$name". Se esperaba $declared.'); // Error tipo
      }
      _values[name] = value; // Actualiza
    } else if (parent != null) { // Si no existe y hay padre
      parent!.assign(name, value); // Delegar al padre
    } else { // No encontrada en cadena
      throw Exception('Variable "$name" no definida.'); // Error de variable no definida
    }
  }

  /// Obtiene el valor de una variable // Documenta get
  Object? get(String name) { // Método get
    if (_values.containsKey(name)) { // Si existe local
      return _values[name]; // Retorna valor local
    } else if (parent != null) { // Si no, buscar en padre
      return parent!.get(name); // Retorna valor del padre
    } else { // No encontrada
      throw Exception('Variable "$name" no definida.'); // Lanza excepción
    }
  }

  bool _checkType(String declared, Object? value) { // Verifica compatibilidad
    if (value == null) return declared == 'null'; // Null
    switch (declared) { // Tipos soportados
      case 'number': return value is NumberValue; // number
      case 'string': return value is StringValue; // string
      case 'bool': return value is BoolValue; // bool
      case 'object': return value is ObjectValue; // object
      case 'function': return value is FunctionValue; // function
      case 'null': return value is NullValue; // null explícito
      default: return true; // Desconocido se acepta
    }
  }
}