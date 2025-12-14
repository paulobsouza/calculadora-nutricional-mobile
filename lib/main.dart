import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Sua configuração local

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase (Responsabilidade do Backend)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const BackendApp());
}

// Uma aplicação temporária só para testar se o Backend sobe sem erros
class BackendApp extends StatelessWidget {
  const BackendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text(
            "Backend & Services Inicializados.\nAguardando Interface Gráfica...",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}