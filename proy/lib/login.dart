import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  void _login() {
    // Aquí puedes agregar la lógica para el inicio de sesión
    // Simulamos un inicio de sesión exitoso
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Inicio de sesión exitoso.'),
    ));
    // Redirigir a la página principal después del inicio de sesión
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/fondo.jpg', // Ruta de la imagen de fondo
              fit: BoxFit.cover,
            ),
          ),
          // Cuadro con el formulario alineado hacia abajo
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(16.0),
              width: double.infinity,
              height: 600, // Ajusta la altura del cuadro del formulario
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7), // Fondo oscuro para el cuadro
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: SingleChildScrollView( // Hacemos el contenido desplazable
                child: Column(
                  children: [
                    // Logo centrado y circular
                    CircleAvatar(
                      radius: 50, // Tamaño del logo
                      backgroundImage: AssetImage('assets/logo.jpg')
                    ),
                    SizedBox(height: 20),
                    // División visual (línea)
                    Divider(
                      color: Colors.white,
                      thickness: 2,
                      indent: 50,
                      endIndent: 50,
                    ),
                    SizedBox(height: 20),
                    // Título "Iniciar sesión" dentro del formulario
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
                        // Redirige a la página de registro
                        Navigator.pushNamed(context, '/register');
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
            borderRadius: BorderRadius.circular(30.0), // Bordes redondeados
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