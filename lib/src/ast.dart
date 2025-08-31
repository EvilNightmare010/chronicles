// Definición de nodos AST y visitantes para Chronicles

/// Nodo base para el AST
abstract class AstNode {
  T accept<T>(AstVisitor<T> visitor);
}

/// Visitante para el AST
abstract class AstVisitor<T> {
  T visitProgram(Program node);
  T visitVarDecl(VarDecl node);
  T visitFunDecl(FunDecl node);
  T visitClassDecl(ClassDecl node);
  T visitBlock(Block node);
  T visitExprStmt(ExprStmt node);
  T visitIfStmt(IfStmt node);
  T visitWhileStmt(WhileStmt node);
  T visitReturnStmt(ReturnStmt node);
  T visitAssign(Assign node);
  T visitBinary(Binary node);
  T visitUnary(Unary node);
  T visitLiteral(Literal node);
  T visitVariable(Variable node);
  T visitCall(Call node);
  T visitGet(Get node);
  T visitSet(Set node);
}

// Programa completo
class Program extends AstNode {
  final List<AstNode> statements;
  Program(this.statements);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitProgram(this);
}

// Declaración de variable
class VarDecl extends AstNode {
  final String name;
  final String? type;
  final AstNode? initializer;
  VarDecl(this.name, this.type, this.initializer);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVarDecl(this);
}

// Declaración de función
class FunDecl extends AstNode {
  final String name;
  final List<String> params;
  final AstNode body;
  FunDecl(this.name, this.params, this.body);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFunDecl(this);
}

// Declaración de clase
class ClassDecl extends AstNode {
  final String name;
  final List<FunDecl> methods;
  ClassDecl(this.name, this.methods);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitClassDecl(this);
}

// Bloque de sentencias
class Block extends AstNode {
  final List<AstNode> statements;
  Block(this.statements);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBlock(this);
}

// Sentencia de expresión
class ExprStmt extends AstNode {
  final AstNode expr;
  ExprStmt(this.expr);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitExprStmt(this);
}

// Sentencia if/elif/else
class IfStmt extends AstNode {
  final AstNode condition;
  final AstNode thenBranch;
  final AstNode? elseBranch;
  IfStmt(this.condition, this.thenBranch, this.elseBranch);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIfStmt(this);
}

// Sentencia while
class WhileStmt extends AstNode {
  final AstNode condition;
  final AstNode body;
  WhileStmt(this.condition, this.body);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitWhileStmt(this);
}

// Sentencia return
class ReturnStmt extends AstNode {
  final AstNode? value;
  ReturnStmt(this.value);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitReturnStmt(this);
}

// Asignación
class Assign extends AstNode {
  final String name;
  final AstNode value;
  Assign(this.name, this.value);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitAssign(this);
}

// Expresión binaria
class Binary extends AstNode {
  final AstNode left;
  final String op;
  final AstNode right;
  Binary(this.left, this.op, this.right);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBinary(this);
}

// Expresión unaria
class Unary extends AstNode {
  final String op;
  final AstNode expr;
  Unary(this.op, this.expr);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitUnary(this);
}

// Literal
class Literal extends AstNode {
  final Object? value;
  Literal(this.value);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitLiteral(this);
}

// Variable
class Variable extends AstNode {
  final String name;
  Variable(this.name);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVariable(this);
}

// Llamada a función
class Call extends AstNode {
  final AstNode callee;
  final List<AstNode> args;
  Call(this.callee, this.args);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitCall(this);
}

// Acceso a propiedad
class Get extends AstNode {
  final AstNode object;
  final String name;
  Get(this.object, this.name);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitGet(this);
}

// Asignación a propiedad
class Set extends AstNode {
  final AstNode object;
  final String name;
  final AstNode value;
  Set(this.object, this.name, this.value);
  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitSet(this);
}