// Funciones nativas para Chronicles (print, len, clock, helpers matemáticos)

import 'value.dart'; // Importa tipos de valores

/// Registro de funciones nativas // Mapa de builtins
Map<String, FunctionValue> builtins = { // Inicio mapa builtins
  'print': FunctionValue('print', ['args'], (List<Value> args) { // print
    print(args.map((v) => v.toString()).join(' ')); // Imprime argumentos
    return NullValue(); // Retorna null
  }, isNative: true), // Marca nativa
  'len': FunctionValue('len', ['obj'], (List<Value> args) { // len
    final obj = args.isNotEmpty ? args[0] : NullValue(); // Primer argumento
    if (obj is StringValue) { // Si es cadena
      return NumberValue(obj.value.length.toDouble()); // Longitud string
    }
    if (obj is ObjectValue) { // Si es objeto
      return NumberValue(obj.fields.length.toDouble()); // Número de campos
    }
    return NullValue(); // Caso no soportado
  }, isNative: true), // Fin len
  'clock': FunctionValue('clock', [], (List<Value> args) { // clock
    return NumberValue(DateTime.now().millisecondsSinceEpoch / 1000.0); // Tiempo en segundos
  }, isNative: true), // Fin clock
  'abs': FunctionValue('abs', ['n'], (List<Value> args) { // abs
    if (args.isNotEmpty && args[0] is NumberValue) { // Valida argumento
      return NumberValue((args[0] as NumberValue).value.abs()); // Valor absoluto
    }
    return NullValue(); // No válido
  }, isNative: true), // Fin abs
  'max': FunctionValue('max', ['a', 'b'], (List<Value> args) { // max
    if (args.length == 2 && args[0] is NumberValue && args[1] is NumberValue) { // Dos números
      return NumberValue((args[0] as NumberValue).value > (args[1] as NumberValue).value ? (args[0] as NumberValue).value : (args[1] as NumberValue).value); // Máximo
    }
    return NullValue(); // Caso no válido
  }, isNative: true), // Fin max
  'min': FunctionValue('min', ['a', 'b'], (List<Value> args) { // min
    if (args.length == 2 && args[0] is NumberValue && args[1] is NumberValue) { // Dos números
      return NumberValue((args[0] as NumberValue).value < (args[1] as NumberValue).value ? (args[0] as NumberValue).value : (args[1] as NumberValue).value); // Mínimo
    }
    return NullValue(); // Caso no válido
  }, isNative: true), // Fin min
}; // Fin mapa