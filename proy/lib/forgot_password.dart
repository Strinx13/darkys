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

        final message = Message()
          ..from = Address('andres.santiago@gownetwork.com.mx', "Soporte")
          ..recipients.add(_emailController.text)
          ..subject = "Código de Recuperación"
          ..text = "Tu código de recuperación es: $_generatedCode";

        try {
          await send(message, smtpServer);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Código enviado al correo ${_emailController.text}')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    } finally {
      await conn?.close();
    }
  }

  Future<void> _resetPassword() async {
    if (_codeController.text != _generatedCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código incorrecto')),
      );
      return;
    }

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();

      // Encriptar nueva contraseña
      String hashedPassword = BCrypt.hashpw(_passwordController.text, BCrypt.gensalt());

      // Actualizar la contraseña en la base de datos
      await conn.query(
        'UPDATE ec_customers SET password = ? WHERE email = ?',
        [hashedPassword, _emailController.text],
      );

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
      appBar: AppBar(title: Text('Recuperar Contraseña')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _codeSent
                ? Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(labelText: 'Código de verificación'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Nueva contraseña'),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _resetPassword,
                        child: Text('Cambiar contraseña'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Correo electrónico'),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _sendCode,
                        child: Text('Enviar código'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
