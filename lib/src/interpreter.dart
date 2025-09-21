// Intérprete walk-the-ast para Chronicles

import 'ast.dart'; // Nodos AST
import 'environment.dart'; // Entornos
import 'value.dart'; // Valores runtime (incluye ClassValue, ObjectValue)
import 'builtins.dart'; // Funciones nativas

/// Intérprete principal para Chronicles // Documentación
class Interpreter implements AstVisitor<Value> { // Clase Interpreter
  final bool verbose; // Modo verboso
  final Environment globals = Environment(); // Entorno global
  Environment _env; // Entorno actual

  Interpreter({this.verbose = false}) : _env = Environment() { // Constructor con verbose
    builtins.forEach((k, v) => globals.define(k, v)); // Registra funciones nativas
  }

  /// Ejecuta el AST completo // Método run
  void run(Program program) { // Ejecuta programa
    _env = Environment(globals); // Crea entorno raíz enlazado a globals
    for (final stmt in program.statements) { // Itera sentencias
      stmt.accept(this); // Ejecuta sentencia
    }
  }

  // Implementación de visitantes para cada nodo
  @override
  Value visitProgram(Program node) { // Visita programa
    for (final stmt in node.statements) { // Recorre sentencias
      stmt.accept(this); // Ejecuta
    }
    return NullValue(); // Devuelve null
  }

  @override
  Value visitVarDecl(VarDecl node) { // Visita declaración variable
    final value = node.initializer?.accept(this) ?? NullValue(); // Eval init
    _env.define(node.name, value, type: node.type); // Define var con tipo
    if (verbose) print('var ${node.name} = $value'); // Log
    return value; // Valor inicial
  }

  @override
  Value visitFunDecl(FunDecl node) { // Visita función
    // Definición anticipada para soportar recursión mutua / directa
    final placeholder = FunctionValue(node.name, node.params, node.body); // Placeholder
    _env.define(node.name, placeholder); // Registra primero
    if (verbose) print('fun ${node.name}'); // Log
    return placeholder; // Retorna función
  }

  @override
  Value visitClassDecl(ClassDecl node) { // Visita clase
    final methods = <String, FunctionValue>{}; // Mapa métodos
    for (final m in node.methods) { // Recorre métodos
      methods[m.name] = FunctionValue(m.name, m.params, m.body); // Registra función
    }
    final cls = ClassValue(node.name, methods); // Crea valor clase
    _env.define(node.name, cls); // Define en entorno
    if (verbose) print('class ${node.name}'); // Log
    return cls; // Retorna clase
  }

  @override
  Value visitBlock(Block node) { // Visita bloque
    final previous = _env; // Guarda entorno
    _env = Environment(previous); // Nuevo scope
    Value result = NullValue(); // Resultado último
    for (final stmt in node.statements) { // Recorre sentencias
      result = stmt.accept(this); // Ejecuta
    }
    _env = previous; // Restaura
    return result; // Devuelve último
  }

  @override
  Value visitExprStmt(ExprStmt node) { // Visita expr stmt
    return node.expr.accept(this); // Evalúa expresión
  }

  @override
  Value visitIfStmt(IfStmt node) { // Visita if
    final cond = node.condition.accept(this); // Eval condición
    if (cond is BoolValue && cond.value) { // Verdadero
      return node.thenBranch.accept(this); // Ejecuta then
    } else if (node.elseBranch != null) { // Else existente
      return node.elseBranch!.accept(this); // Ejecuta else
    }
    return NullValue(); // Sin rama
  }

  @override
  Value visitWhileStmt(WhileStmt node) { // Visita while
    while ((node.condition.accept(this) as BoolValue).value) { // Mientras true
      node.body.accept(this); // Ejecuta cuerpo
    }
    return NullValue(); // Fin
  }

  @override
  Value visitReturnStmt(ReturnStmt node) { // Visita return
    final val = node.value?.accept(this) ?? NullValue(); // Eval valor
    throw ReturnSignal(val); // Lanza señal
  }

  @override
  Value visitAssign(Assign node) { // Visita asignación
    final value = node.value.accept(this); // Eval RHS
    _env.assign(node.name, value); // Asigna variable
    return value; // Devuelve valor
  }

  @override
  Value visitBinary(Binary node) { // Visita binario
    final left = node.left.accept(this); // Eval izquierda
    if (node.op == 'and') { // Operador and
      if (left is BoolValue && !left.value) return BoolValue(false); // Corto falso
      final rightEval = node.right.accept(this); // Eval derecha
      if (rightEval is BoolValue) return BoolValue(rightEval.value); // Dev bool
      return BoolValue(false); // Falso por defecto
    }
    if (node.op == 'or') { // Operador or
      if (left is BoolValue && left.value) return BoolValue(true); // Corto true
      final rightEval = node.right.accept(this); // Eval derecha
      if (rightEval is BoolValue) return BoolValue(rightEval.value); // Dev bool
      return BoolValue(false); // Falso por defecto
    }
    final right = node.right.accept(this); // Eval derecha
    switch (node.op) { // Según operador
      case '+': // Suma / concatenación
        if (left is NumberValue && right is NumberValue) { // Números
          return NumberValue(left.value + right.value); // Suma
        }
        if (left is StringValue || right is StringValue) { // Concatenación
          return StringValue(left.toString() + right.toString()); // Concat
        }
        break; // Fin +
      case '-': // Resta
        if (left is NumberValue && right is NumberValue) { // Números
          return NumberValue(left.value - right.value); // Resta
        }
        break; // Fin -
      case '*': // Multiplicación
        if (left is NumberValue && right is NumberValue) { // Números
          return NumberValue(left.value * right.value); // Multiplica
        }
        break; // Fin *
      case '/': // División
        if (left is NumberValue && right is NumberValue) { // Números
          return NumberValue(left.value / right.value); // Divide
        }
        break; // Fin /
      case '%': // Módulo
        if (left is NumberValue && right is NumberValue) { // Números
          return NumberValue(left.value % right.value); // Resto
        }
        break; // Fin %
      case '==': // Igualdad
        return BoolValue(left.toString() == right.toString()); // Compara
      case '!=': // Desigualdad
        return BoolValue(left.toString() != right.toString()); // Compara
      case '<': // Menor
        if (left is NumberValue && right is NumberValue) { // Números
          return BoolValue(left.value < right.value); // Resultado
        }
        break; // Fin <
      case '<=': // Menor o igual
        if (left is NumberValue && right is NumberValue) { // Números
          return BoolValue(left.value <= right.value); // Resultado
        }
        break; // Fin <=
      case '>': // Mayor
        if (left is NumberValue && right is NumberValue) { // Números
          return BoolValue(left.value > right.value); // Resultado
        }
        break; // Fin >
      case '>=': // Mayor o igual
        if (left is NumberValue && right is NumberValue) { // Números
          return BoolValue(left.value >= right.value); // Resultado
        }
        break; // Fin >=
    }
    return NullValue(); // Por defecto
  }

  @override
  Value visitUnary(Unary node) { // Visita unario
    final expr = node.expr.accept(this); // Eval operand
    switch (node.op) { // Según operador
      case '-': // Negativo
        if (expr is NumberValue) { // Número
          return NumberValue(-expr.value); // Negado
        }
        break; // Fin -
      case '!': // Not
        if (expr is BoolValue) { // Booleano
          return BoolValue(!expr.value); // Invertido
        }
        break; // Fin !
    }
    return NullValue(); // Default
  }

  @override
  Value visitLiteral(Literal node) { // Visita literal
    if (node.value == null) return NullValue(); // null
    if (node.value is double) return NumberValue(node.value as double); // número
    if (node.value is String) return StringValue(node.value as String); // cadena
    if (node.value is bool) return BoolValue(node.value as bool); // booleano
    return NullValue(); // otro
  }

  @override
  Value visitVariable(Variable node) { // Visita variable
    final val = _env.get(node.name); // Obtiene valor
    if (val is Value) return val; // Devuelve si válido
    return NullValue(); // Fallback
  }

  @override
  Value visitCall(Call node) { // Visita llamada
    final callee = node.callee.accept(this); // Eval callee
    final args = node.args.map((a) => a.accept(this)).toList(); // Eval args
    if (callee is ClassValue) { // Llamada a clase => instancia
      final instance = ObjectValue(callee.name); // Nueva instancia
      // this disponible
      final initMethod = callee.methods['__init__']; // Busca init
      if (initMethod != null) { // Si existe
        final previous = _env; // Guarda entorno
        _env = Environment(previous); // Nuevo scope
        _env.define('this', instance); // Define this
        for (int i = 0; i < initMethod.params.length; i++) { // Params
          _env.define(initMethod.params[i], i < args.length ? args[i] : NullValue()); // Asigna
        }
        try { // Ejecuta init
          (initMethod.body as AstNode).accept(this); // Ignora return valor
        } on ReturnSignal catch (_) { // Ignorar return explícito
          // no-op
        }
        _env = previous; // Restaura
      }
      return instance; // Retorna instancia
    }
    if (callee is BoundMethod) { // Método ligado
      final method = callee.method; // Método real
      final previous = _env; // Guarda entorno
      _env = Environment(previous); // Nuevo scope
      _env.define('this', callee.instance); // Define this
      for (int i = 0; i < method.params.length; i++) { // Parámetros
        _env.define(method.params[i], i < args.length ? args[i] : NullValue()); // Bind
      }
      Value result = NullValue(); // Resultado
      try { // Ejecuta
        result = (method.body as AstNode).accept(this); // Cuerpo
      } on ReturnSignal catch (r) { // Return
        result = r.value; // Valor
      }
      _env = previous; // Restaura
      return result; // Devuelve
    }
    if (callee is FunctionValue) { // Si función
      if (callee.isNative) { // Nativa
        return callee.body(args); // Ejecuta
      } else { // Usuario
        final previous = _env; // Guarda entorno
        _env = Environment(previous); // Nuevo scope
        for (int i = 0; i < callee.params.length; i++) { // Parámetros
          _env.define(callee.params[i], i < args.length ? args[i] : NullValue()); // Bind param
        }
        Value result = NullValue(); // Inicial
        try { // Ejecuta cuerpo
          result = (callee.body as AstNode).accept(this); // Resultado
        } on ReturnSignal catch (r) { // Captura return
          result = r.value; // Valor retornado
        }
        _env = previous; // Restaura
        return result; // Devuelve
      }
    }
    return NullValue(); // No callable
  }

  @override
  Value visitGet(Get node) { // Acceso propiedad
    final obj = node.object.accept(this); // Eval objeto
    if (obj is ObjectValue) { // Si instancia
      if (obj.fields.containsKey(node.name)) { // Campo
        return obj.fields[node.name]!; // Valor campo
      }
      // Método de clase
      final clsVal = _env.get(obj.className); // Recupera clase
      if (clsVal is ClassValue && clsVal.methods.containsKey(node.name)) { // Método existe
        return BoundMethod(obj, clsVal.methods[node.name]!); // Método ligado
      }
    }
    return NullValue(); // No encontrado
  }

  @override
  Value visitSet(Set node) { // Asignación propiedad
    final obj = node.object.accept(this); // Eval objeto
    if (obj is ObjectValue) { // Si instancia
      final val = node.value.accept(this); // Eval valor
      obj.fields[node.name] = val; // Asigna campo
      return val; // Devuelve valor
    }
    return NullValue(); // No asignable
  }

  @override
  Value visitForStmt(ForStmt node) { // Visita for
    final iterableVal = node.iterable.accept(this); // Eval iterable
    if (iterableVal is NumberValue) { // Si número
      final previous = _env; // Guarda
      _env = Environment(previous); // Nuevo scope
      _env.define(node.iterator, NullValue()); // Declara iterador
      for (int i = 0; i < iterableVal.value; i++) { // Itera rango
        _env.assign(node.iterator, NumberValue(i.toDouble())); // Actualiza
        try { // Ejecuta cuerpo
          node.body.accept(this); // Cuerpo
        } on ReturnSignal catch (r) { // Return interno
          _env = previous; // Restaura
          return r.value; // Dev valor
        }
      }
      _env = previous; // Restaura
    }
    return NullValue(); // Sin valor
  }
}

// Excepción interna para manejar retornos 
class ReturnSignal implements Exception { // Señal return
  final Value value; // Valor retornado
  ReturnSignal(this.value); // Constructor asigna valor
}