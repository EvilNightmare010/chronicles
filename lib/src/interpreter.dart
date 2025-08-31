// Intérprete walk-the-ast para Chronicles

import 'ast.dart';
import 'environment.dart';
import 'value.dart';

/// Intérprete principal para Chronicles
class Interpreter implements AstVisitor<Value> {
  final bool verbose;
  final Environment globals = Environment();
  Environment _env;

  Interpreter({this.verbose = false}) : _env = Environment();

  /// Ejecuta el AST completo
  void run(Program program) {
    _env = Environment(globals);
    for (final stmt in program.statements) {
      stmt.accept(this);
    }
  }

  // Implementación de visitantes para cada nodo
  @override
  Value visitProgram(Program node) {
    for (final stmt in node.statements) {
      stmt.accept(this);
    }
    return NullValue();
  }

  @override
  Value visitVarDecl(VarDecl node) {
    final value = node.initializer?.accept(this) ?? NullValue();
    _env.define(node.name, value);
    if (verbose) print('var ${node.name} = $value');
    return value;
  }

  @override
  Value visitFunDecl(FunDecl node) {
    final fun = FunctionValue(node.name, node.params, node.body);
    _env.define(node.name, fun);
    if (verbose) print('fun ${node.name}');
    return fun;
  }

  @override
  Value visitClassDecl(ClassDecl node) {
    // Las clases se representan como funciones constructoras
    _env.define(node.name, node);
    if (verbose) print('class ${node.name}');
    return NullValue();
  }

  @override
  Value visitBlock(Block node) {
    final previous = _env;
    _env = Environment(previous);
    Value result = NullValue();
    for (final stmt in node.statements) {
      result = stmt.accept(this);
    }
    _env = previous;
    return result;
  }

  @override
  Value visitExprStmt(ExprStmt node) {
    return node.expr.accept(this);
  }

  @override
  Value visitIfStmt(IfStmt node) {
    final cond = node.condition.accept(this);
    if (cond is BoolValue && cond.value) {
      return node.thenBranch.accept(this);
    } else if (node.elseBranch != null) {
      return node.elseBranch!.accept(this);
    }
    return NullValue();
  }

  @override
  Value visitWhileStmt(WhileStmt node) {
    while ((node.condition.accept(this) as BoolValue).value) {
      node.body.accept(this);
    }
    return NullValue();
  }

  @override
  Value visitReturnStmt(ReturnStmt node) {
    return node.value?.accept(this) ?? NullValue();
  }

  @override
  Value visitAssign(Assign node) {
    final value = node.value.accept(this);
    _env.assign(node.name, value);
    return value;
  }

  @override
  Value visitBinary(Binary node) {
    final left = node.left.accept(this);
    final right = node.right.accept(this);
    switch (node.op) {
      case '+':
        if (left is NumberValue && right is NumberValue) {
          return NumberValue(left.value + right.value);
        }
        if (left is StringValue || right is StringValue) {
          return StringValue(left.toString() + right.toString());
        }
        break;
      case '-':
        if (left is NumberValue && right is NumberValue) {
          return NumberValue(left.value - right.value);
        }
        break;
      case '*':
        if (left is NumberValue && right is NumberValue) {
          return NumberValue(left.value * right.value);
        }
        break;
      case '/':
        if (left is NumberValue && right is NumberValue) {
          return NumberValue(left.value / right.value);
        }
        break;
      case '%':
        if (left is NumberValue && right is NumberValue) {
          return NumberValue(left.value % right.value);
        }
        break;
      case '==':
        return BoolValue(left.toString() == right.toString());
      case '!=':
        return BoolValue(left.toString() != right.toString());
      case '<':
        if (left is NumberValue && right is NumberValue) {
          return BoolValue(left.value < right.value);
        }
        break;
      case '<=':
        if (left is NumberValue && right is NumberValue) {
          return BoolValue(left.value <= right.value);
        }
        break;
      case '>':
        if (left is NumberValue && right is NumberValue) {
          return BoolValue(left.value > right.value);
        }
        break;
      case '>=':
        if (left is NumberValue && right is NumberValue) {
          return BoolValue(left.value >= right.value);
        }
        break;
    }
    return NullValue();
  }

  @override
  Value visitUnary(Unary node) {
    final expr = node.expr.accept(this);
    switch (node.op) {
      case '-':
        if (expr is NumberValue) {
          return NumberValue(-expr.value);
        }
        break;
      case '!':
        if (expr is BoolValue) {
          return BoolValue(!expr.value);
        }
        break;
    }
    return NullValue();
  }

  @override
  Value visitLiteral(Literal node) {
    if (node.value == null) return NullValue();
    if (node.value is double) return NumberValue(node.value as double);
    if (node.value is String) return StringValue(node.value as String);
    if (node.value is bool) return BoolValue(node.value as bool);
    return NullValue();
  }

  @override
  Value visitVariable(Variable node) {
    final val = _env.get(node.name);
    if (val is Value) return val;
    return NullValue();
  }

  @override
  Value visitCall(Call node) {
    final callee = node.callee.accept(this);
    final args = node.args.map((a) => a.accept(this)).toList();
    if (callee is FunctionValue) {
      if (callee.isNative) {
        return callee.body(args);
      } else {
        // Función definida por el usuario
        final previous = _env;
        _env = Environment(previous);
        for (int i = 0; i < callee.params.length; i++) {
          _env.define(callee.params[i], i < args.length ? args[i] : NullValue());
        }
        final result = (callee.body as AstNode).accept(this);
        _env = previous;
        return result;
      }
    }
    return NullValue();
  }

  @override
  Value visitGet(Get node) {
    // No implementado: acceso a propiedades de objetos
    return NullValue();
  }

  @override
  Value visitSet(Set node) {
    // No implementado: asignación a propiedades de objetos
    return NullValue();
  }
}