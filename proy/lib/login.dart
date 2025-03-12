import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:proy/db_connection.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect(); // Se obtiene la conexión

      var results = await conn.query(
        'SELECT * FROM ec_customers WHERE email = ? AND password = ?',
        [_emailController.text, _passwordController.text],
      );

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Inicio de sesión exitoso.'),
        ));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Correo o contraseña incorrectos.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error de conexión: $e'),
      ));
    } finally {
      await conn?.close(); // Se cierra la conexión
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              width: double.infinity,
              height: 600,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/logo.jpg'),
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: Colors.white,
                      thickness: 2,
                      indent: 50,
                      endIndent: 50,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(_emailController, 'Correo electrónico'),
                    _buildTextField(_passwordController, 'Contraseña', obscureText: true),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Iniciar sesión'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        '¿No tienes una cuenta? Regístrate aquí',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          fillColor: Colors.grey[800],
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
