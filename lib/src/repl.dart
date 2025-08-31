// REPL interactivo para Chronicles con historial y modo verbose

import 'dart:io';
import 'scanner.dart';
import 'parser.dart';
import 'interpreter.dart';

void startRepl({bool verbose = false}) {
  print('Chronicles REPL (Ctrl+C para salir)');
  final history = <String>[];
  final interpreter = Interpreter(verbose: verbose);
  while (true) {
    stdout.write('>>> ');
    final line = stdin.readLineSync();
    if (line == null) break;
    history.add(line);
    try {
      final scanner = Scanner(line, '<repl>');
      final tokens = scanner.scanTokens();
      final parserChron = Parser(tokens);
      final ast = parserChron.parse();
      interpreter.run(ast);
    } catch (e) {
      print('Error: $e');
    }
  }
}