// Funciones nativas para Chronicles (print, len, clock, helpers matemáticos)

import 'value.dart';

/// Registro de funciones nativas
Map<String, FunctionValue> builtins = {
  'print': FunctionValue('print', ['args'], (List<Value> args) {
    print(args.map((v) => v.toString()).join(' '));
    return NullValue();
  }, isNative: true),
  'len': FunctionValue('len', ['obj'], (List<Value> args) {
    final obj = args.isNotEmpty ? args[0] : NullValue();
    if (obj is StringValue) {
      return NumberValue(obj.value.length.toDouble());
    }
    if (obj is ObjectValue) {
      return NumberValue(obj.fields.length.toDouble());
    }
    return NullValue();
  }, isNative: true),
  'clock': FunctionValue('clock', [], (List<Value> args) {
    return NumberValue(DateTime.now().millisecondsSinceEpoch / 1000.0);
  }, isNative: true),
  'abs': FunctionValue('abs', ['n'], (List<Value> args) {
    if (args.isNotEmpty && args[0] is NumberValue) {
      return NumberValue((args[0] as NumberValue).value.abs());
    }
    return NullValue();
  }, isNative: true),
  'max': FunctionValue('max', ['a', 'b'], (List<Value> args) {
    if (args.length == 2 && args[0] is NumberValue && args[1] is NumberValue) {
      return NumberValue((args[0] as NumberValue).value > (args[1] as NumberValue).value ? (args[0] as NumberValue).value : (args[1] as NumberValue).value);
    }
    return NullValue();
  }, isNative: true),
  'min': FunctionValue('min', ['a', 'b'], (List<Value> args) {
    if (args.length == 2 && args[0] is NumberValue && args[1] is NumberValue) {
      return NumberValue((args[0] as NumberValue).value < (args[1] as NumberValue).value ? (args[0] as NumberValue).value : (args[1] as NumberValue).value);
    }
    return NullValue();
  }, isNative: true),
};