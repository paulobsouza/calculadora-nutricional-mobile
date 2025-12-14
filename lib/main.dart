import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'controllers/food_controller.dart';
import 'views/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Inicia Firebase

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        // Seus outros controllers...
        // Aqui usamos ProxyProvider para passar o ID do usuário para o FoodController!
        ChangeNotifierProxyProvider<AuthController, FoodController>(
          create: (_) => FoodController(),
          update: (_, auth, foodController) {
            // Atualiza o controller de comida com o ID do usuário logado
            foodController!.updateUserId(auth.user?.uid);
            return foodController;
          },
        ),
      ],
      child: MaterialApp(
        home:
            LoginScreen(), // O próprio LoginScreen decide se mostra Home ou Login
      ),
    ),
  );
}
