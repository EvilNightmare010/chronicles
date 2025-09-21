// Representación de funciones, objetos y tipos nativos para Chronicles

/// Valor base para el intérprete
abstract class Value {} // Define jerarquía de valores

/// Valor nulo // Representa null
class NullValue extends Value { // Clase NullValue
  @override // Sobrescribe toString
  String toString() => 'null'; // Devuelve representación textual
}

/// Valor numérico // Números de punto flotante
class NumberValue extends Value { // Clase NumberValue
  final double value; // Almacena número
  NumberValue(this.value); // Constructor
  @override // toString
  String toString() => value.toString(); // Texto del número
}

/// Valor cadena // Strings
class StringValue extends Value { // Clase StringValue
  final String value; // Texto interno
  StringValue(this.value); // Constructor
  @override // toString
  String toString() => '"$value"'; // Representación con comillas
}

/// Valor booleano // Booleans
class BoolValue extends Value { // Clase BoolValue
  final bool value; // Valor bool
  BoolValue(this.value); // Constructor
  @override // toString
  String toString() => value ? 'true' : 'false'; // Texto booleano
}

/// Valor función // Funciones nativas o de usuario
class FunctionValue extends Value { // Clase FunctionValue
  final String name; // Nombre de función
  final List<String> params; // Parámetros
  final dynamic body; // Puede ser AstNode o función nativa
  final bool isNative; // Marca nativa
  FunctionValue(this.name, this.params, this.body, {this.isNative = false}); // Constructor
  @override // toString
  String toString() => '<fun $name>'; // Representación simbólica
}

/// Valor objeto // Instancias de clases (futuro)
class ObjectValue extends Value { // Clase ObjectValue
  final String className; // Nombre de clase
  final Map<String, Value> fields = {}; // Campos dinámicos
  ObjectValue(this.className); // Constructor
  @override // toString
  String toString() => '<object $className>'; // Texto simbólico
}

/// Valor clase // Representa definición de clase
class ClassValue extends Value { // Clase ClassValue
  final String name; // Nombre de clase
  final Map<String, FunctionValue> methods; // Métodos
  ClassValue(this.name, this.methods); // Constructor
  @override // toString
  String toString() => '<class $name>'; // Texto
}

/// Método ligado a instancia // Para this
class BoundMethod extends Value { // Clase BoundMethod
  final ObjectValue instance; // Instancia
  final FunctionValue method; // Método
  BoundMethod(this.instance, this.method); // Constructor
  @override // toString
  String toString() => '<bound ${method.name}>'; // Texto
}