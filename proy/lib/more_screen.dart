import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';
import 'package:provider/provider.dart';
import 'package:proy/app_state.dart';
import 'package:proy/mainScreen.dart';
import 'profile_edit_screen.dart';
import 'package:proy/models/shipping_address.dart';
import 'package:proy/screens/address_form_screen.dart';
import 'package:proy/screens/order_list_screen.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  Map<String, dynamic>? userData;
  List<ShippingAddress> _addresses = [];
  bool _isLoadingAddresses = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAddresses();
  }

  Future<void> _loadUserData() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isLoggedIn) return;

    setState(() {
      userData = appState.userData;
    });
  }

  Future<void> _loadAddresses() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final customerId = appState.userId;

    if (customerId == null) return;

    setState(() => _isLoadingAddresses = true);

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      var results = await conn.query(
        'SELECT id, name, email, phone, country, state, city, address, customer_id, is_default, zip_code FROM ec_customer_addresses WHERE customer_id = ?',
        [customerId],
      );

      _addresses = results
          .map((row) => ShippingAddress.fromMap({
                'id': row['id'],
                'name': row['name'],
                'email': row['email'],
                'phone': row['phone'],
                'country': row['country'],
                'state': row['state'],
                'city': row['city'],
                'address': row['address'],
                'customer_id': row['customer_id'],
                'is_default': row['is_default'],
                'zip_code': row['zip_code'],
              }))
          .toList();

      setState(() {});
    } catch (e) {
      print('Error al cargar direcciones: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las direcciones')),
      );
    } finally {
      await conn?.close();
      setState(() => _isLoadingAddresses = false);
    }
  }

  Future<void> _deleteAddress(ShippingAddress address) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final customerId = appState.userId;

    if (customerId == null) return;

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      await conn.query(
        'DELETE FROM ec_customer_addresses WHERE id = ? AND customer_id = ?',
        [address.id, customerId],
      );

      setState(() {
        _addresses.removeWhere((a) => a.id == address.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dirección eliminada correctamente')),
      );
    } catch (e) {
      print('Error al eliminar dirección: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la dirección')),
      );
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
          'Configuracion',
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
                    builder: (context) => ProfileEditScreen(
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
                      backgroundImage: userData?['avatar'] != null
                          ? NetworkImage(
                              userData!['avatar'].toString().startsWith(
                                        'http',
                                      )
                                  ? userData!['avatar']
                                  : 'https://darkysfishshop.gownetwork.com.mx/storage/' +
                                      userData!['avatar'],
                            )
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
            _buildAddressSection(),
            _buildOptionItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Mis Ordenes',
              subtitle: 'Revisa tus ordenes',
              onTap: () {
                if (!Provider.of<AppState>(context, listen: false).isLoggedIn) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Debes iniciar sesión primero')),
                  );
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderListScreen()),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              subtitle: 'Salir de esta cuenta',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Cerrar Sesión'),
                      content: Text('¿Estás seguro que deseas cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context); // Cerrar el diálogo
                            final appState = Provider.of<AppState>(
                              context,
                              listen: false,
                            );
                            await appState.logout();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sesión cerrada exitosamente'),
                              ),
                            );
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MainScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          child: Text(
                            'Cerrar Sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
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
        leading: Icon(icon, color: Colors.red),
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

  Widget _buildAddressSection() {
    if (!Provider.of<AppState>(context).isLoggedIn) {
      return ListTile(
        leading: Icon(Icons.location_on_outlined),
        title: Text('Direcciones de envío'),
        subtitle: Text('Inicia sesión para gestionar tus direcciones'),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Debes iniciar sesión primero')),
          );
        },
      );
    }

    return ExpansionTile(
      leading: Icon(Icons.location_on_outlined),
      title: Text('Direcciones de envío'),
      children: [
        if (_isLoadingAddresses)
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_addresses.isEmpty)
          ListTile(
            title: Text('No tienes direcciones guardadas'),
            subtitle: Text('Agrega una nueva dirección'),
            trailing: Icon(Icons.add),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddressFormScreen()),
              );
              if (result == true) {
                _loadAddresses();
              }
            },
          )
        else
          ..._addresses
              .map((address) => ListTile(
                    title: Text(address.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(address.address),
                        if (address.city != null || address.state != null)
                          Text('${address.city ?? ''}, ${address.state ?? ''}'),
                        if (address.isDefault)
                          Text(
                            'Dirección predeterminada',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddressFormScreen(address: address),
                              ),
                            );
                            if (result == true) {
                              _loadAddresses();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Eliminar dirección'),
                                content: Text(
                                    '¿Estás seguro de que deseas eliminar esta dirección?'),
                                actions: [
                                  TextButton(
                                    child: Text('Cancelar'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteAddress(address);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ))
              .toList(),
        if (_addresses.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Agregar nueva dirección'),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddressFormScreen()),
                );
                if (result == true) {
                  _loadAddresses();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
