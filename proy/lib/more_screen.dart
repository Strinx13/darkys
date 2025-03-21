import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';
import 'package:provider/provider.dart';
import 'package:proy/app_state.dart';
import 'package:proy/mainScreen.dart';
import 'profile_edit_screen.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isLoggedIn) return;

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      var results = await conn.query(
        'SELECT name, email, phone, avatar FROM ec_customers WHERE id = ?',
        [1], // Aquí deberías usar el ID del usuario actual desde appState
      );

      if (results.isNotEmpty) {
        setState(() {
          userData = {
            'name': results.first['name'],
            'email': results.first['email'],
            'phone': results.first['phone'],
            'avatar': results.first['avatar'],
          };
        });
      }
    } catch (e) {
      print('Error al cargar datos del usuario: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<void> _logout(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.logout();

    // Navegar al MainScreen después de cerrar sesión
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Más',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Sección de perfil
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProfileEditScreen(
                          userData: userData,
                          onProfileUpdated: _loadUserData,
                        ),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(20),
                color: Colors.white,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          userData?['avatar'] != null
                              ? NetworkImage(userData!['avatar'])
                              : AssetImage('assets/logo.jpg') as ImageProvider,
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['name'] ?? 'Usuario',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          userData?['email'] ?? 'correo@ejemplo.com',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.edit, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Lista de opciones
            _buildOptionItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Mis Ordenes',
              subtitle: 'Revisa tus ordenes',
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.location_on_outlined,
              title: 'Direcciones de envio',
              subtitle: 'Gestiona tus direcciones de envio',
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.payment_outlined,
              title: 'Metodos de pago',
              subtitle: 'Gestiona tus metodos de pago',
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.notifications_outlined,
              title: 'Notificaciones',
              subtitle: 'Gestiona tus notificaciones',
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.security_outlined,
              title: 'Privacidad y seguridad',
              subtitle: 'Gestiona tus preferencias de privacidad',
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.help_outline,
              title: 'Ayuda y soporte',
              subtitle: 'Obtén ayuda y contáctanos',
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.info_outline,
              title: 'Acerca de nosotros',
              subtitle: 'Lee más sobre nuestra app',
              onTap: () {},
            ),
            _buildOptionItem(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              subtitle: 'Salir de esta cuenta',
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
