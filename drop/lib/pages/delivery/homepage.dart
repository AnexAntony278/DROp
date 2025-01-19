import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Column(
                children: [
                  Text('User Name'),
                  ListTile(title: Text("Settings")),
                ],
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, 'createroutepage');
              },
              child: Card(
                child: Container(
                  color: Colors.amber,
                  height: 100,
                  width: double.infinity,
                  child: const Icon(Icons.add),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
