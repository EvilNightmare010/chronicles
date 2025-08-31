// Analizador sintáctico por descenso recursivo para Chronicles

import 'token.dart';
import 'ast.dart';

/// Parser para Chronicles
/// Convierte una lista de tokens en un AST
class Parser {
  final List<Token> tokens;
  int _current = 0;

  Parser(this.tokens);

  /// Punto de entrada principal
  Program parse() {
    final statements = <AstNode>[];
    while (!_isAtEnd()) {
      statements.add(_declaration());
    }
    return Program(statements);
  }

  // Maneja declaraciones (var, fun, class)
  AstNode _declaration() {
    if (_match([TokenType.var_])) return _varDecl();
    if (_match([TokenType.fun])) return _funDecl();
    if (_match([TokenType.class_])) return _classDecl();
    return _statement();
  }

  // Declaración de variable
  VarDecl _varDecl() {
    final name = _consume(TokenType.identifier, 'Se esperaba nombre de variable.').lexeme;
    String? type;
    if (_match([TokenType.colon])) {
      type = _consume(TokenType.identifier, 'Se esperaba tipo.').lexeme;
    }
    _consume(TokenType.assign, 'Se esperaba "=".');
    final initializer = _expression();
    _consume(TokenType.newline, 'Se esperaba salto de línea.');
    return VarDecl(name, type, initializer);
  }

  // Declaración de función
  FunDecl _funDecl() {
    final name = _consume(TokenType.identifier, 'Se esperaba nombre de función.').lexeme;
    _consume(TokenType.lparen, 'Se esperaba "(".');
    final params = <String>[];
    if (!_check(TokenType.rparen)) {
      do {
        params.add(_consume(TokenType.identifier, 'Se esperaba nombre de parámetro.').lexeme);
      } while (_match([TokenType.comma]));
    }
    _consume(TokenType.rparen, 'Se esperaba ")".');
    if (_match([TokenType.arrow])) {
      _expression(); // Ignorar tipo de retorno por ahora
    }
    _consume(TokenType.colon, 'Se esperaba ":".');
    _consume(TokenType.newline, 'Se esperaba salto de línea.');
    final body = _block();
    return FunDecl(name, params, body);
  }

  // Declaración de clase
  ClassDecl _classDecl() {
    final name = _consume(TokenType.identifier, 'Se esperaba nombre de clase.').lexeme;
    _consume(TokenType.colon, 'Se esperaba ":".');
    _consume(TokenType.newline, 'Se esperaba salto de línea.');
    final methods = <FunDecl>[];
    while (_check(TokenType.indent)) {
      _advance();
      while (!_check(TokenType.dedent) && !_isAtEnd()) {
        methods.add(_funDecl());
      }
      _advance(); // dedent
    }
    return ClassDecl(name, methods);
  }

  // Sentencias
  AstNode _statement() {
    if (_match([TokenType.if_])) return _ifStmt();
    if (_match([TokenType.while_])) return _whileStmt();
    if (_match([TokenType.return_])) return _returnStmt();
    if (_match([TokenType.print_])) return _printStmt();
    return _exprStmt();
  }

  // Sentencia if/elif/else
  IfStmt _ifStmt() {
    final condition = _expression();
    _consume(TokenType.colon, 'Se esperaba ":".');
    _consume(TokenType.newline, 'Se esperaba salto de línea.');
    final thenBranch = _block();
    AstNode? elseBranch;
    if (_match([TokenType.elif_, TokenType.else_])) {
      _consume(TokenType.colon, 'Se esperaba ":".');
      _consume(TokenType.newline, 'Se esperaba salto de línea.');
      elseBranch = _block();
    }
    return IfStmt(condition, thenBranch, elseBranch);
  }

  // Sentencia while
  WhileStmt _whileStmt() {
    final condition = _expression();
    _consume(TokenType.colon, 'Se esperaba ":".');
    _consume(TokenType.newline, 'Se esperaba salto de línea.');
    final body = _block();
    return WhileStmt(condition, body);
  }

  // Sentencia return
  ReturnStmt _returnStmt() {
    AstNode? value;
    if (!_check(TokenType.newline)) {
      value = _expression();
    }
    _consume(TokenType.newline, 'Se esperaba salto de línea.');
    return ReturnStmt(value);
  }

  // Sentencia print
  ExprStmt _printStmt() {
    final expr = _expression();
    _consume(TokenType.newline, 'Se esperaba salto de línea.');
    return ExprStmt(expr);
  }

  // Sentencia de expresión
  ExprStmt _exprStmt() {
    final expr = _expression();
    _consume(TokenType.newline, 'Se esperaba salto de línea.');
    return ExprStmt(expr);
  }

  // Bloque de sentencias (indentación)
  Block _block() {
    final statements = <AstNode>[];
    if (_match([TokenType.indent])) {
      while (!_check(TokenType.dedent) && !_isAtEnd()) {
        statements.add(_declaration());
      }
      _consume(TokenType.dedent, 'Se esperaba dedent.');
    }
    return Block(statements);
  }

  // Expresiones
  AstNode _expression() {
    return _assignment();
  }

  AstNode _assignment() {
    final expr = _equality();
    if (_match([TokenType.assign])) {
      final value = _assignment();
      if (expr is Variable) {
        return Assign(expr.name, value);
      }
      throw Exception('Asignación inválida.');
    }
    return expr;
  }

  AstNode _equality() {
    var expr = _comparison();
    while (_match([TokenType.eq, TokenType.neq])) {
      final op = _previous().lexeme;
      final right = _comparison();
      expr = Binary(expr, op, right);
    }
    return expr;
  }

  AstNode _comparison() {
    var expr = _term();
    while (_match([TokenType.lt, TokenType.le, TokenType.gt, TokenType.ge])) {
      final op = _previous().lexeme;
      final right = _term();
      expr = Binary(expr, op, right);
    }
    return expr;
  }

  AstNode _term() {
    var expr = _factor();
    while (_match([TokenType.plus, TokenType.minus])) {
      final op = _previous().lexeme;
      final right = _factor();
      expr = Binary(expr, op, right);
    }
    return expr;
  }

  AstNode _factor() {
    var expr = _unary();
    while (_match([TokenType.star, TokenType.slash, TokenType.percent])) {
      final op = _previous().lexeme;
      final right = _unary();
      expr = Binary(expr, op, right);
    }
    return expr;
  }

  AstNode _unary() {
    if (_match([TokenType.minus, TokenType.neq])) { // Solo operadores válidos
      final op = _previous().lexeme;
      final expr = _unary();
      return Unary(op, expr);
    }
    return _call();
  }

  AstNode _call() {
    var expr = _primary();
    while (_match([TokenType.lparen])) {
      final args = <AstNode>[];
      if (!_check(TokenType.rparen)) {
        do {
          args.add(_expression());
        } while (_match([TokenType.comma]));
      }
      _consume(TokenType.rparen, 'Se esperaba ")".');
      expr = Call(expr, args);
    }
    return expr;
  }

  AstNode _primary() {
    if (_match([TokenType.number])) {
      return Literal(double.parse(_previous().lexeme));
    }
    if (_match([TokenType.string])) {
      return Literal(_previous().lexeme);
    }
    if (_match([TokenType.bool])) {
      return Literal(_previous().lexeme == 'true');
    }
    if (_match([TokenType.null_])) {
      return Literal(null);
    }
    if (_match([TokenType.identifier])) {
      return Variable(_previous().lexeme);
    }
    if (_match([TokenType.lparen])) {
      final expr = _expression();
      _consume(TokenType.rparen, 'Se esperaba ")".');
      return expr;
    }
    throw Exception('Expresión inválida.');
  }

  // Utilidades del parser
  bool _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return tokens[_current].type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => tokens[_current].type == TokenType.eof;

  Token _previous() => tokens[_current - 1];

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();
    throw Exception(message);
  }
}