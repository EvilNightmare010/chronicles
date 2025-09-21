// Definición de nodos AST y visitantes para Chronicles

/// Nodo base para el AST // Interfaz base
abstract class AstNode { // Clase abstracta raíz
  T accept<T>(AstVisitor<T> visitor); // Método de doble despacho
} // Fin AstNode

/// Visitante para el AST // Patrón Visitor
abstract class AstVisitor<T> { // Visitante genérico
  T visitProgram(Program node); // Visita programa
  T visitVarDecl(VarDecl node); // Visita declaración var
  T visitFunDecl(FunDecl node); // Visita declaración función
  T visitClassDecl(ClassDecl node); // Visita declaración clase
  T visitBlock(Block node); // Visita bloque
  T visitExprStmt(ExprStmt node); // Visita sentencia expresión
  T visitIfStmt(IfStmt node); // Visita if
  T visitWhileStmt(WhileStmt node); // Visita while
  T visitForStmt(ForStmt node); // Visita for
  T visitReturnStmt(ReturnStmt node); // Visita return
  T visitAssign(Assign node); // Visita asignación
  T visitBinary(Binary node); // Visita binaria
  T visitUnary(Unary node); // Visita unaria
  T visitLiteral(Literal node); // Visita literal
  T visitVariable(Variable node); // Visita variable
  T visitCall(Call node); // Visita llamada
  T visitGet(Get node); // Visita acceso propiedad
  T visitSet(Set node); // Visita asignación propiedad
} // Fin AstVisitor

// Programa completo // Nodo raíz del archivo
class Program extends AstNode { // Clase Program
  final List<AstNode> statements; // Lista de sentencias top-level
  Program(this.statements); // Constructor
  @override // Implementación accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitProgram(this); // Despacho a visitante
} // Fin Program

// Declaración de variable // var nombre [: tipo] = expr
class VarDecl extends AstNode { // Clase VarDecl
  final String name; // Identificador
  final String? type; // Tipo opcional
  final AstNode? initializer; // Expresión inicial
  VarDecl(this.name, this.type, this.initializer); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVarDecl(this); // Visita
} // Fin VarDecl

// Declaración de función // fun nombre(params): bloque
class FunDecl extends AstNode { // Clase FunDecl
  final String name; // Nombre
  final List<String> params; // Parámetros
  final AstNode body; // Cuerpo (Block)
  FunDecl(this.name, this.params, this.body); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFunDecl(this); // Visita
} // Fin FunDecl

// Declaración de clase // class Nombre: métodos
class ClassDecl extends AstNode { // Clase ClassDecl
  final String name; // Nombre de clase
  final List<FunDecl> methods; // Lista de métodos
  ClassDecl(this.name, this.methods); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitClassDecl(this); // Visita
} // Fin ClassDecl

// Bloque de sentencias // {sentencias} por indentación
class Block extends AstNode { // Clase Block
  final List<AstNode> statements; // Sentencias internas
  Block(this.statements); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBlock(this); // Visita
} // Fin Block

// Sentencia de expresión // expr standalone
class ExprStmt extends AstNode { // Clase ExprStmt
  final AstNode expr; // Expresión
  ExprStmt(this.expr); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitExprStmt(this); // Visita
} // Fin ExprStmt

// Sentencia if/elif/else // if cond: ... [else: ...]
class IfStmt extends AstNode { // Clase IfStmt
  final AstNode condition; // Condición booleana
  final AstNode thenBranch; // Rama verdadera
  final AstNode? elseBranch; // Rama alternativa opcional
  IfStmt(this.condition, this.thenBranch, this.elseBranch); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIfStmt(this); // Visita
} // Fin IfStmt

// Sentencia while // while cond: ...
class WhileStmt extends AstNode { // Clase WhileStmt
  final AstNode condition; // Condición de bucle
  final AstNode body; // Cuerpo a repetir
  WhileStmt(this.condition, this.body); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitWhileStmt(this); // Visita
} // Fin WhileStmt

// Sentencia for (for var in iterable) // Bucle for
class ForStmt extends AstNode { // Clase ForStmt
  final String iterator; // Variable iteradora
  final AstNode iterable; // Expresión iterable
  final AstNode body; // Cuerpo bucle
  ForStmt(this.iterator, this.iterable, this.body); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitForStmt(this); // Visita
} // Fin ForStmt

// Sentencia return // return expr
class ReturnStmt extends AstNode { // Clase ReturnStmt
  final AstNode? value; // Valor retornado opcional
  ReturnStmt(this.value); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitReturnStmt(this); // Visita
} // Fin ReturnStmt

// Asignación // nombre = expr
class Assign extends AstNode { // Clase Assign
  final String name; // Identificador
  final AstNode value; // Valor asignado
  Assign(this.name, this.value); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitAssign(this); // Visita
} // Fin Assign

// Expresión binaria // left op right
class Binary extends AstNode { // Clase Binary
  final AstNode left; // Operando izquierdo
  final String op; // Operador
  final AstNode right; // Operando derecho
  Binary(this.left, this.op, this.right); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBinary(this); // Visita
} // Fin Binary

// Expresión unaria // op expr
class Unary extends AstNode { // Clase Unary
  final String op; // Operador unario
  final AstNode expr; // Operando
  Unary(this.op, this.expr); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitUnary(this); // Visita
} // Fin Unary

// Literal // Valor inmediato
class Literal extends AstNode { // Clase Literal
  final Object? value; // Valor almacenado
  Literal(this.value); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitLiteral(this); // Visita
} // Fin Literal

// Variable // Referencia a identificador
class Variable extends AstNode { // Clase Variable
  final String name; // Nombre variable
  Variable(this.name); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitVariable(this); // Visita
} // Fin Variable

// Llamada a función // callee(args)
class Call extends AstNode { // Clase Call
  final AstNode callee; // Expresión invocable
  final List<AstNode> args; // Lista argumentos
  Call(this.callee, this.args); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitCall(this); // Visita
} // Fin Call

// Acceso a propiedad // objeto.nombre
class Get extends AstNode { // Clase Get
  final AstNode object; // Objeto base
  final String name; // Nombre propiedad
  Get(this.object, this.name); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitGet(this); // Visita
} // Fin Get

// Asignación a propiedad // objeto.nombre = valor
class Set extends AstNode { // Clase Set
  final AstNode object; // Objeto base
  final String name; // Nombre propiedad
  final AstNode value; // Valor asignado
  Set(this.object, this.name, this.value); // Constructor
  @override // accept
  T accept<T>(AstVisitor<T> visitor) => visitor.visitSet(this); // Visita
} // Fin Set