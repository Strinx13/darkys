import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
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
          'More',
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
            Container(
              padding: EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/logo.jpg'),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'John Doe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'john.doe@example.com',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
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
              title: 'Logout',
              subtitle: 'Salir de esta cuenta',
              onTap: () {},
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
} 