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
    if (_codeController.text != _generatedCode) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Código incorrecto')));
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
                            _buildTextField(
                              _passwordController,
                              'Nueva contraseña',
                              obscureText: true,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _resetPassword,
                              child: Text('Cambiar contraseña'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.blueAccent,
                                ),
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
                              child: Text('Enviar código'),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Colors.blueAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Volver al inicio de sesión',
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
  }) {
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
