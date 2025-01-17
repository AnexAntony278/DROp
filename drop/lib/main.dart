import 'package:drop/pages/authentication/authentication.dart';
import 'package:drop/pages/delivery/add_delivery_page.dart';
import 'package:drop/pages/delivery/create_route_page.dart';
import 'package:drop/pages/delivery/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DROp',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Montserrat'),
      home: const SafeArea(
        child: AuthPage(),
      ),
      routes: {
        'homepage': (context) => const HomePage(),
        'adddeliverypage': (context) => const AddDeliveriesPage(),
        "createroutepage": (context) => const CreateRoutePage()
      },
    );
  }
}
