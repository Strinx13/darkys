import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:proy/db_connection.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    // Encriptar la contraseña con bcrypt
    String hashedPassword = BCrypt.hashpw(_passwordController.text, BCrypt.gensalt());

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();

      await conn.query(
        '''INSERT INTO ec_customers (id, name, email, password, avatar, dob, phone, remember_token, created_at, updated_at, confirmed_at, email_verify_token) 
           VALUES (NULL, ?, ?, ?, NULL, NULL, ?, NULL, NOW(), NOW(), NOW(), NULL)''',
        [
          _nameController.text,
          _emailController.text,
          hashedPassword, // Contraseña encriptada
          _phoneController.text,
        ],
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registro exitoso.')),
      );

      Navigator.push(context,
      MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar usuario: $e')),
      );
    } finally {
      await conn?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/fondo.jpg', fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              width: double.infinity,
              height: 750,
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
                    Divider(color: Colors.white, thickness: 2, indent: 50, endIndent: 50),
                    SizedBox(height: 20),
                    Text('Registrarse', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    _buildTextField(_nameController, 'Nombre completo'),
                    _buildTextField(_emailController, 'Correo electrónico'),
                    _buildTextField(_phoneController, 'Número de teléfono'),
                    _buildTextField(_passwordController, 'Contraseña', obscureText: true),
                    _buildTextField(_confirmPasswordController, 'Confirmar contraseña', obscureText: true),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
                      child: Text('Registrarse'),
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder:  (context) => LoginPage()), 
                        );
                      },
                      child: Text('¿Ya tienes una cuenta? Inicia sesión aquí', style: TextStyle(color: Colors.blueAccent)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
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
