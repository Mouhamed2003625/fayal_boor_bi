import 'package:flutter/material.dart';
import 'package:weer_bi_dena/screens/dashboard_screen.dart';
import 'package:weer_bi_dena/screens/home_screen.dart';
import 'package:weer_bi_dena/screens/login_screen.dart';
// On importe notre nouvel écran pour pouvoir l'utiliser
import 'screens/clients/clients_screen.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // On retire le Scaffold d'ici...
      // ...et on le remplace par notre HomeScreen !
      home: HomeScreen(),
      debugShowCheckedModeBanner: false, // Petite astuce pour enlever la bannière "Debug"
    );
  }
}