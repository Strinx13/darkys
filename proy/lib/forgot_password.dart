import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _generatedCode;
  bool _codeSent = false;

  // Generar código aleatorio de 6 dígitos
  String _generateCode() {
    return (Random().nextInt(900000) + 100000).toString();
  }

  Future<void> _sendCode() async {
    // Validar campo de correo vacío
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa tu correo electrónico'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar formato de correo electrónico
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa un correo electrónico válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();

      // Verificar si el correo existe en la base de datos
      var results = await conn.query(
        'SELECT id FROM ec_customers WHERE email = ?',
        [_emailController.text],
      );

      if (results.isNotEmpty) {
        _generatedCode = _generateCode();
        setState(() {
          _codeSent = true;
        });

        // Configuración SMTP para Gmail
        final smtpServer = SmtpServer(
          'mail.gownetwork.com.mx', // Servidor SMTP
          username: 'andres.santiago@gownetwork.com.mx',
          password: '5_lh0YC2kjl&',
          port: 465, // Puerto SMTP con SSL
          ssl: true, // Habilita SSL para el puerto 465
          allowInsecure: false, // Mantén en false para seguridad
        );

        final message =
            Message()
              ..from = Address('andres.santiago@gownetwork.com.mx', "Soporte")
              ..recipients.add(_emailController.text)
              ..subject = "Código de Recuperación"
              ..text = "Tu código de recuperación es: $_generatedCode";

        try {
          await send(message, smtpServer);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Código enviado al correo ${_emailController.text}',
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al enviar el correo: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('El correo no está registrado.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      await conn?.close();
    }
  }

  Future<void> _resetPassword() async {
    // Validar código vacío
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa el código de verificación'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar contraseña vacía
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa la nueva contraseña'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar longitud mínima de contraseña
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_codeController.text != _generatedCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código incorrecto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();

      // Encriptar nueva contraseña
      String hashedPassword = BCrypt.hashpw(
        _passwordController.text,
        BCrypt.gensalt(),
      );

      // Actualizar la contraseña en la base de datos
      await conn.query('UPDATE ec_customers SET password = ? WHERE email = ?', [
        hashedPassword,
        _emailController.text,
      ]);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contraseña actualizada con éxito')),
      );

      Navigator.pop(context); // Volver a la pantalla de login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la contraseña: $e')),
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
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/logo.jpg'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Recuperar Contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  _codeSent
                      ? Column(
                          children: [
                            _buildTextField(
                              _codeController,
                              'Código de verificación',
                            ),
                            SizedBox(height: 8),
                            _buildTextField(
                              _passwordController,
                              'Nueva contraseña',
                              obscureText: true,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: Size(double.infinity, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Cambiar contraseña',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildTextField(
                              _emailController,
                              'Correo electrónico',
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _sendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: Size(double.infinity, 45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                'Enviar código',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Volver al inicio de sesión',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.black45,
        ),
      ),
    );
  }
}
