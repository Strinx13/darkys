import 'package:flutter/material.dart';
import 'package:proy/models/shipping_address.dart';
import 'package:proy/db_connection.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:proy/app_state.dart';

class AddressFormScreen extends StatefulWidget {
  final ShippingAddress? address;

  AddressFormScreen({this.address});

  @override
  _AddressFormScreenState createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _zipCodeController;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? '');
    _emailController = TextEditingController(text: widget.address?.email ?? '');
    _phoneController = TextEditingController(text: widget.address?.phone ?? '');
    _countryController =
        TextEditingController(text: widget.address?.country ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _addressController =
        TextEditingController(text: widget.address?.address ?? '');
    _zipCodeController =
        TextEditingController(text: widget.address?.zipCode ?? '');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final appState = Provider.of<AppState>(context, listen: false);
    final customerId = appState.userId;

    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Debes iniciar sesión para guardar direcciones')),
      );
      setState(() => _isLoading = false);
      return;
    }

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();

      if (widget.address == null) {
        // Insertar nueva dirección
        await conn.query(
          'INSERT INTO ec_customer_addresses (name, email, phone, country, state, city, address, customer_id, is_default, zip_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            _nameController.text,
            _emailController.text,
            _phoneController.text,
            _countryController.text,
            _stateController.text,
            _cityController.text,
            _addressController.text,
            customerId,
            _isDefault ? 1 : 0,
            _zipCodeController.text,
          ],
        );
      } else {
        // Actualizar dirección existente
        await conn.query(
          'UPDATE ec_customer_addresses SET name = ?, email = ?, phone = ?, country = ?, state = ?, city = ?, address = ?, is_default = ?, zip_code = ? WHERE id = ? AND customer_id = ?',
          [
            _nameController.text,
            _emailController.text,
            _phoneController.text,
            _countryController.text,
            _stateController.text,
            _cityController.text,
            _addressController.text,
            _isDefault ? 1 : 0,
            _zipCodeController.text,
            widget.address!.id,
            customerId,
          ],
        );
      }

      if (_isDefault) {
        // Actualizar otras direcciones como no predeterminadas
        await conn.query(
          'UPDATE ec_customer_addresses SET is_default = ? WHERE customer_id = ? AND id != ?',
          [0, customerId, widget.address?.id ?? -1],
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      print('Error al guardar la dirección: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la dirección')),
      );
    } finally {
      await conn?.close();
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.address == null ? 'Nueva Dirección' : 'Editar Dirección'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un nombre';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un correo';
                        }
                        if (!value.contains('@')) {
                          return 'Por favor ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un teléfono';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _countryController,
                      decoration: InputDecoration(
                        labelText: 'País',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un país';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _stateController,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un estado';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _cityController,
                      decoration: InputDecoration(
                        labelText: 'Ciudad',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una ciudad';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa una dirección';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _zipCodeController,
                      decoration: InputDecoration(
                        labelText: 'Código Postal',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa un código postal';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    CheckboxListTile(
                      title: Text('Establecer como dirección predeterminada'),
                      value: _isDefault,
                      onChanged: (bool? value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveAddress,
                      child: Text('Guardar Dirección'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
