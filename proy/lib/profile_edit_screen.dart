import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:proy/app_state.dart';

class ProfileEditScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final Function onProfileUpdated;

  ProfileEditScreen({required this.userData, required this.onProfileUpdated});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _avatarPath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData?['name'] ?? '';
    _emailController.text = widget.userData?['email'] ?? '';
    _phoneController.text = widget.userData?['phone'] ?? '';
    _avatarPath = widget.userData?['avatar'];
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _avatarPath = image.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      final appState = Provider.of<AppState>(context, listen: false);

      if (appState.userId == null) {
        throw Exception('No hay un usuario activo');
      }

      // Actualizamos los datos del usuario
      await conn.query(
        'UPDATE ec_customers SET name = ?, email = ?, phone = ? WHERE id = ?',
        [
          _nameController.text,
          _emailController.text,
          _phoneController.text,
          appState.userId,
        ],
      );

      // Actualizamos los datos en AppState
      await appState.updateUserData();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Perfil actualizado con éxito')));

      widget.onProfileUpdated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el perfil: $e')),
      );
    } finally {
      await conn?.close();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        _avatarPath != null
                            ? (_avatarPath!.startsWith('http')
                                ? NetworkImage(_avatarPath!)
                                : _avatarPath!.startsWith('/')
                                ? NetworkImage(
                                  'https://darkysfishshop.gownetwork.com.mx/storage' +
                                      _avatarPath!,
                                )
                                : !_avatarPath!.startsWith('assets')
                                ? NetworkImage(
                                  'https://darkysfishshop.gownetwork.com.mx/storage/' +
                                      _avatarPath!,
                                )
                                : FileImage(File(_avatarPath!))
                                    as ImageProvider)
                            : AssetImage('assets/logo.jpg'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child:
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Guardar cambios'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
