import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Info Example',
      initialRoute: '/login',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Fondo oscuro para toda la app
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black87, // Fondo oscuro para la AppBar
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent, // Color del texto en el TextButton
          ),
        ),
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userData = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;

    return Scaffold(
      appBar: AppBar(title: Text('Welcome Home')),
      body: Center(
        child: userData == null
            ? Text('No user data available.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Welcome, ${userData['email']}'),
                  SizedBox(height: 20),
                  Text('User Info:'),
                  Text('Email: ${userData['email']}'),
                ],
              ),
      ),
    );
  }
}
