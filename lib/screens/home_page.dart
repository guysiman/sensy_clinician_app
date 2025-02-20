import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
                child: Text('Home Page',
                    style: Theme.of(context).textTheme.titleMedium)),
            Container(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                child: const Text("Logout"),
                onPressed: () {
                  Navigator.pushNamed(context, '/signinpage');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
