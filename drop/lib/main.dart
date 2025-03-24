import 'package:drop/pages/authentication/authentication.dart';
import 'package:drop/pages/delivery/create_route_page.dart';
import 'package:drop/pages/delivery/delivery_page.dart';
import 'package:drop/pages/delivery/homepage.dart';
import 'package:drop/pages/manager/manger_dashboard.dart';
import 'package:drop/services/app_preferences_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferencesService.instance.init();

  final String? userToken =
      AppPreferencesService.instance.prefs.getString("user_token");

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
        appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            titleTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 23,
              fontFamily: 'Montserrat',
            )),
      ),
      home: isLoggedIn ? const HomePage() : const AuthPage(),
      routes: {
        "authenticationpage": (context) => const AuthPage(),
        "homepage": (context) => const HomePage(),
        "createroutepage": (context) => const CreateRoutePage(),
        "deliverypage": (context) => const DeliveryPage(),
        "managerdashboard": (context) => const ManagerDashBoard()
      },
    );
  }
}
