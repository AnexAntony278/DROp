import 'package:drop/pages/authentication/authentication.dart';
import 'package:drop/pages/delivery/create_route_page.dart';
import 'package:drop/pages/delivery/delivery_page.dart';
import 'package:drop/pages/delivery/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? userToken = prefs.getString('user_token');
  debugPrint("\n\n $userToken loggedin");
  runApp(MyApp(isLoggedIn: (userToken != null && userToken.isNotEmpty)));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DROp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 158, 244, 244)),
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 23,
              fontFamily: 'Montserrat',
            )),
      ),
      home: isLoggedIn ? const HomePage() : const AuthPage(),
      routes: {
        "homepage": (context) => const HomePage(),
        "createroutepage": (context) => const CreateRoutePage(),
        "deliverypage": (context) => const DeliveryPage()
      },
    );
  }
}
