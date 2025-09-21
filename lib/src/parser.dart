// Analizador sintáctico por descenso recursivo para Chronicles

import 'token.dart'; // Importa definiciones de tokens
import 'ast.dart'; // Importa definiciones de nodos AST

/// Parser para Chronicles
/// Convierte una lista de tokens en un AST
class Parser { // Clase Parser
  final List<Token> tokens; // Lista de tokens de entrada
  int _current = 0; // Índice actual en la lista

  Parser(this.tokens); // Constructor asigna tokens

  /// Punto de entrada principal // Método público
  Program parse() { // parse principal
    final statements = <AstNode>[]; // Acumulador de sentencias
    while (!_isAtEnd()) { // Mientras no EOF
      _skipNoise(); // Saltar ruido entre declaraciones
      statements.add(_declaration()); // Agrega declaración parseada
      _skipNoise(); // Limpiar después
    }
    return Program(statements); // Retorna programa raíz
  }

  // Maneja declaraciones (var, fun, class) // Router de declaraciones
  AstNode _declaration() { // Método declaración
    if (_match([TokenType.var_])) return _varDecl(); // var -> variable
    if (_match([TokenType.fun])) return _funDecl(); // fun -> función
    if (_match([TokenType.class_])) return _classDecl(); // class -> clase
    return _statement(); // Si no, sentencia
  }

  // Declaración de variable // var nombre [: tipo] = expr newline
  VarDecl _varDecl() { // Método variable
    final name = _consume(TokenType.identifier, 'Se esperaba nombre de variable.').lexeme; // Nombre
    String? type; // Posible tipo
    if (_match([TokenType.colon])) { // Si hay : tipo
      // Aceptar identificador o palabras clave de tipo
      if (_match([
        TokenType.identifier,
        TokenType.number_,
        TokenType.string_,
        TokenType.bool_,
        TokenType.object_,
        TokenType.function_,
        TokenType.null_kw
      ])) {
        type = _previous().lexeme; // Captura lexema del tipo
      } else {
        throw Exception('Se esperaba tipo.'); // Error tipo
      }
    }
    _consume(TokenType.assign, 'Se esperaba "=".'); // Consume =
    final initializer = _expression(); // Expresión inicializadora
    _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Fin de línea
    return VarDecl(name, type, initializer); // Nodo VarDecl
  }

  // Declaración de función // fun nombre(params) [-> type] : \n block
  FunDecl _funDecl() { // Método función
    final name = _consume(TokenType.identifier, 'Se esperaba nombre de función.').lexeme; // Nombre función
    _consume(TokenType.lparen, 'Se esperaba "(".'); // (
    final params = <String>[]; // Lista parámetros
    if (!_check(TokenType.rparen)) { // Si no cierra
      do { // Leer parámetros separados por coma
        params.add(_consume(TokenType.identifier, 'Se esperaba nombre de parámetro.').lexeme); // Param
      } while (_match([TokenType.comma])); // Mientras coma
    }
    _consume(TokenType.rparen, 'Se esperaba ")".'); // )
    if (_match([TokenType.arrow])) { // Si hay -> tipo retorno
      _expression(); // Ignora expresión (tipo) por ahora
    }
    _consume(TokenType.colon, 'Se esperaba ":".'); // :
    _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Fin cabecera
    final body = _block(); // Bloque cuerpo
    return FunDecl(name, params, body); // Nodo FunDecl
  }

  // Declaración de clase // class Nombre : \n (indent métodos)
  ClassDecl _classDecl() { // Método clase
    final name = _consume(TokenType.identifier, 'Se esperaba nombre de clase.').lexeme; // Nombre clase
    _consume(TokenType.colon, 'Se esperaba ":".'); // :
    _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Fin cabecera
    final methods = <FunDecl>[]; // Lista métodos
    while (_check(TokenType.indent)) { // Mientras indent
      _advance(); // Consume indent
      while (!_check(TokenType.dedent) && !_isAtEnd()) { // Hasta dedent
        _skipNoise(); // Saltar newlines/comentarios antes del método
        if (_check(TokenType.dedent)) break; // Salir si bloque termina
        _consume(TokenType.fun, 'Se esperaba "fun" en método de clase.'); // Asegura fun
        methods.add(_funDecl()); // Añade método
        _skipNoise(); // Saltar ruido tras método
      }
      _advance(); // Consume dedent
    }
    return ClassDecl(name, methods); // Nodo ClassDecl
  }

  // Sentencias // Router de sentencias
  AstNode _statement() { // Método sentencia
    if (_match([TokenType.if_])) return _ifStmt(); // if
    if (_match([TokenType.while_])) return _whileStmt(); // while
    if (_match([TokenType.for_])) return _forStmt(); // for
    if (_match([TokenType.return_])) return _returnStmt(); // return
    if (_match([TokenType.print_])) return _printStmt(); // print
    return _exprStmt(); // Expresión por defecto
  }

  // Sentencia for: for IDENT in expr : newline block // Gramática for
  ForStmt _forStmt() { // Método for
    final iterator = _consume(TokenType.identifier, 'Se esperaba nombre de variable iteradora.').lexeme; // Nombre iterador
    _consume(TokenType.in_, 'Se esperaba palabra clave "in".'); // in
    final iterable = _expression(); // Expresión iterable
    _consume(TokenType.colon, 'Se esperaba ":".'); // :
    _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Fin cabecera
    final body = _block(); // Bloque cuerpo
    return ForStmt(iterator, iterable, body); // Nodo ForStmt
  }

  // Sentencia if/elif/else // Condicional
  IfStmt _ifStmt() { // Método if
    final condition = _expression(); // Condición
    _consume(TokenType.colon, 'Se esperaba ":".'); // :
    _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Fin línea
    final thenBranch = _block(); // Rama then
    AstNode? elseBranch; // Posible else
    if (_match([TokenType.elif_, TokenType.else_])) { // elif/else
      _consume(TokenType.colon, 'Se esperaba ":".'); // :
      _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Fin línea
      elseBranch = _block(); // Rama alternativa
    }
    return IfStmt(condition, thenBranch, elseBranch); // Nodo IfStmt
  }

  // Sentencia while // Bucle while
  WhileStmt _whileStmt() { // Método while
    final condition = _expression(); // Condición
    _consume(TokenType.colon, 'Se esperaba ":".'); // :
    _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Fin línea
    final body = _block(); // Cuerpo
    return WhileStmt(condition, body); // Nodo WhileStmt
  }

  // Sentencia return // return [expr]\n
  ReturnStmt _returnStmt() { // Método return
    AstNode? value; // Valor opcional
    if (!_check(TokenType.newline)) { // Si no newline
      value = _expression(); // Expresión valor
    }
    _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Consume newline
    return ReturnStmt(value); // Nodo ReturnStmt
  }

  // Sentencia print // print expr\n
  ExprStmt _printStmt() { // Método print
    final expr = _expression(); // Expresión a imprimir
    _consume(TokenType.newline, 'Se esperaba salto de línea.'); // Fin línea
    return ExprStmt(expr); // Nodo ExprStmt
  }

  // Sentencia de expresión // expr\n
  ExprStmt _exprStmt() { // Método expr stmt
    final expr = _expression(); // Expresión
    if (_check(TokenType.newline)) { // Si hay newline
      _advance(); // Consume
    }
    return ExprStmt(expr); // Nodo ExprStmt
  }

  // Bloque de sentencias (indentación) // block ::= indent decl* dedent
  Block _block() { // Método block
    final statements = <AstNode>[]; // Lista sentencias
    if (_match([TokenType.indent])) { // Si indent
      while (!_check(TokenType.dedent) && !_isAtEnd()) { // Hasta dedent
        _skipNoise(); // Limpia antes
        if (_check(TokenType.dedent)) break; // Evitar parse vacío
        statements.add(_declaration()); // Añade declaración
        _skipNoise(); // Limpia después
      }
      _consume(TokenType.dedent, 'Se esperaba dedent.'); // Consume dedent
    }
    return Block(statements); // Nodo Block
  }

  // Expresiones // Entrada expresiones
  AstNode _expression() { // Método expression
    return _or(); // Inicia en or
  }

  AstNode _or() { // or lógico (baja precedencia) // Producción or
    var expr = _and(); // Lado izquierdo
    while (_match([TokenType.or_])) { // Mientras operador or
      final op = _previous().lexeme; // Operador
      final right = _and(); // Lado derecho
      expr = Binary(expr, op, right); // Nodo Binary
    }
    return expr; // Resultado or
  }

  AstNode _and() { // and lógico // Producción and
    var expr = _assignment(); // Lado izquierdo
    while (_match([TokenType.and_])) { // Mientras and
      final op = _previous().lexeme; // Operador
      final right = _assignment(); // Lado derecho
      expr = Binary(expr, op, right); // Nodo Binary
    }
    return expr; // Resultado and
  }

  AstNode _assignment() { // Asignación // Producción assignment
    final expr = _equality(); // LHS
    if (_match([TokenType.assign])) { // Si =
      final value = _assignment(); // RHS recursivo
      if (expr is Variable) { // Debe ser variable
        return Assign(expr.name, value); // Nodo Assign
      } else if (expr is Get) { // Asignación a propiedad
        return Set(expr.object, expr.name, value); // Nodo Set
      }
      throw Exception('Asignación inválida.'); // Error
    }
    return expr; // Sin asignación
  }

  AstNode _equality() { // Igualdad // Producción equality
    var expr = _comparison(); // LHS
    while (_match([TokenType.eq, TokenType.neq])) { // Mientras == o !=
      final op = _previous().lexeme; // Operador
      final right = _comparison(); // RHS
      expr = Binary(expr, op, right); // Nodo Binary
    }
    return expr; // Resultado igualdad
  }

  AstNode _comparison() { // Comparación // Producción comparison
    var expr = _term(); // LHS
    while (_match([TokenType.lt, TokenType.le, TokenType.gt, TokenType.ge])) { // Operadores rel
      final op = _previous().lexeme; // Operador
      final right = _term(); // RHS
      expr = Binary(expr, op, right); // Nodo Binary
    }
    return expr; // Resultado comparación
  }

  AstNode _term() { // Suma/resta // Producción term
    var expr = _factor(); // LHS
    while (_match([TokenType.plus, TokenType.minus])) { // + o -
      final op = _previous().lexeme; // Operador
      final right = _factor(); // RHS
      expr = Binary(expr, op, right); // Nodo Binary
    }
    return expr; // Resultado term
  }

  AstNode _factor() { // Multiplicación/división/módulo // Producción factor
    var expr = _unary(); // LHS
    while (_match([TokenType.star, TokenType.slash, TokenType.percent])) { // *, /, %
      final op = _previous().lexeme; // Operador
      final right = _unary(); // RHS
      expr = Binary(expr, op, right); // Nodo Binary
    }
    return expr; // Resultado factor
  }

  AstNode _unary() { // Unarios // Producción unary
    if (_match([TokenType.minus, TokenType.bang])) { // - o !
      final op = _previous().lexeme; // Operador
      final expr = _unary(); // Operando
      return Unary(op, expr); // Nodo Unary
    }
    return _call(); // Pasa a call
  }

  AstNode _call() { // Llamadas // Producción call
    var expr = _primary(); // Expresión base
    while (_match([TokenType.lparen])) { // Mientras (
      final args = <AstNode>[]; // Lista argumentos
      if (!_check(TokenType.rparen)) { // Si no cierra
        do { // Recoge argumentos
          args.add(_expression()); // Arg
        } while (_match([TokenType.comma])); // Comas
      }
      _consume(TokenType.rparen, 'Se esperaba ")".'); // )
      expr = Call(expr, args); // Nodo llamada
      // Después de una llamada puede continuar con accesos por punto
    }
    // Encadenar accesos a propiedades con '.'
    while (_match([TokenType.dot])) { // Mientras punto
      final name = _consume(TokenType.identifier, 'Se esperaba nombre de propiedad.').lexeme; // Nombre prop
      expr = Get(expr, name); // Nodo Get
    }
    return expr; // Resultado call
  }

  AstNode _primary() { // Primarios // Producción primary
    if (_match([TokenType.number])) { // Número
      return Literal(double.parse(_previous().lexeme)); // Literal num
    }
    if (_match([TokenType.string])) { // Cadena
      return Literal(_previous().lexeme); // Literal str
    }
    if (_match([TokenType.bool])) { // Booleano
      return Literal(_previous().lexeme == 'true'); // Literal bool
    }
    if (_match([TokenType.null_, TokenType.null_kw])) { // null literal
      return Literal(null); // Literal null
    }
    if (_match([TokenType.identifier])) { // Identificador
      return Variable(_previous().lexeme); // Nodo Variable
    }
    if (_match([TokenType.lparen])) { // (
      final expr = _expression(); // Subexpresión
      if (_check(TokenType.rparen)) { // ) presente
        _advance(); // Consumir )
      } else if (!(_check(TokenType.newline) || _check(TokenType.dedent) || _check(TokenType.eof))) {
        // Si no estamos ante un delimitador razonable, entonces sí es error
        _consume(TokenType.rparen, 'Se esperaba ")".');
      }
      return expr; // Retorna agrupación (cierre implícito posible)
    }
    // Recuperación: si encontramos un ')' aislado lo consumimos y devolvemos null
    if (_check(TokenType.rparen)) { // Paréntesis de cierre inesperado
      _advance(); // Consumir
      return Literal(null); // Recuperar con null
    }
    if (_isAtEnd()) {
      throw Exception('Expresión inválida: EOF inesperado.');
    }
    final t = tokens[_current];
    throw Exception('Expresión inválida (token: ${t.type} lexeme="${t.lexeme}" línea ${t.line} col ${t.column}).');
  }

  // Utilidades del parser // Helpers
  bool _match(List<TokenType> types) { // Verifica alguno y avanza
    for (final type in types) { // Itera tipos
      if (_check(type)) { // Si coincide
        _advance(); // Avanza
        return true; // Éxito
      }
    }
    return false; // Sin coincidencia
  }

  bool _check(TokenType type) { // Mira tipo actual
    if (_isAtEnd()) return false; // EOF -> falso
    return tokens[_current].type == type; // Comparación
  }

  Token _advance() { // Avanza y devuelve previo
    if (!_isAtEnd()) _current++; // Incrementa índice
    return _previous(); // Retorna token anterior
  }

  bool _isAtEnd() => tokens[_current].type == TokenType.eof; // TRUE si EOF

  Token _previous() => tokens[_current - 1]; // Token previo

  Token _consume(TokenType type, String message) { // Exige tipo
    if (_check(type)) return _advance(); // Devuelve si coincide
    throw Exception(message); // Lanza error
  }

  // Salta tokens de ruido: newlines y comentarios encadenados
  void _skipNoise() {
    bool avanzo = true; // Control
    while (avanzo && !_isAtEnd()) { // Mientras avance
      avanzo = false; // Reset
      if (_check(TokenType.newline) || _check(TokenType.comment)) { // Ruido
        _advance(); // Consume
        avanzo = true; // Marcó avance
      }
    }
  }
}