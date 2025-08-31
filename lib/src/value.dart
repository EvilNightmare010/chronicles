// Representación de funciones, objetos y tipos nativos para Chronicles

/// Valor base para el intérprete
abstract class Value {}

/// Valor nulo
class NullValue extends Value {
  @override
  String toString() => 'null';
}

/// Valor numérico
class NumberValue extends Value {
  final double value;
  NumberValue(this.value);
  @override
  String toString() => value.toString();
}

/// Valor cadena
class StringValue extends Value {
  final String value;
  StringValue(this.value);
  @override
  String toString() => '"$value"';
}

/// Valor booleano
class BoolValue extends Value {
  final bool value;
  BoolValue(this.value);
  @override
  String toString() => value ? 'true' : 'false';
}

/// Valor función
class FunctionValue extends Value {
  final String name;
  final List<String> params;
  final dynamic body; // Puede ser AstNode o función nativa
  final bool isNative;
  FunctionValue(this.name, this.params, this.body, {this.isNative = false});
  @override
  String toString() => '<fun $name>';
}

/// Valor objeto
class ObjectValue extends Value {
  final String className;
  final Map<String, Value> fields = {};
  ObjectValue(this.className);
  @override
  String toString() => '<object $className>';
}