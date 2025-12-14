import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import 'home.dart'; // Sua tela principal

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // O Consumer escuta mudanças no AuthController
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        // Se já estiver logado, redireciona (ou mostra a Home direto no main.dart)
        if (authController.user != null) {
          return HomeScreen();
        }

        return Scaffold(
          body: Center(
            child: authController.isLoading
                ? CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood, size: 80, color: Colors.blue),
                      SizedBox(height: 20),
                      Text("Minha Dieta App", style: TextStyle(fontSize: 24)),
                      SizedBox(height: 50),
                      ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        label: Text("Entrar com Google"),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                        ),
                        onPressed: () async {
                          String? error = await authController
                              .loginWithGoogle();
                          if (error != null && context.mounted) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(error)));
                          }
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
