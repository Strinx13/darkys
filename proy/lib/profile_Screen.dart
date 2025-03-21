import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mi Perfil"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto de perfil (puedes agregar una imagen si lo deseas)
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/profile_picture.jpg'),
              ),
            ),
            SizedBox(height: 20),

            // Información del usuario
            Text(
              "Nombre:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("Juan Pérez", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            Text(
              "Correo electrónico:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("juan.perez@example.com", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),

            Text(
              "Teléfono:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("+123 456 789", style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),

            // Botón para editar perfil
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para editar el perfil (puedes agregar más funcionalidad)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Editando perfil...")));
                },
                child: Text("Editar Perfil"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  textStyle: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
