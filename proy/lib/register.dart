import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  void _register() {
    // Aquí puedes agregar la lógica para el registro
    // Simulamos un registro exitoso
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Registro exitoso.'),
    ));
    // Redirigir a la página de login después del registro
    Navigator.pushReplacementNamed(context, '/login');
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
              height: 750,// Ajusta la altura del cuadro del formulario
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
                    // Título "Registrarse" dentro del formulario
                    Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildTextField(_nameController, 'Nombre completo'),
                    _buildTextField(_emailController, 'Correo electrónico'),
                    _buildTextField(_birthYearController, 'Año de nacimiento'),
                    _buildTextField(_phoneController, 'Número de teléfono'),
                    _buildTextField(_passwordController, 'Contraseña', obscureText: true),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _register,
                      child: Text('Registrarse'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blueAccent),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // Redirige a la página de login
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text(
                        '¿Ya tienes una cuenta? Inicia sesión aquí',
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
