import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:provider/provider.dart';
import 'package:proy/models/cart_state.dart';
import 'package:proy/screens/order_success_screen.dart';
import 'package:proy/models/shipping_address.dart';
import 'package:proy/db_connection.dart';
import 'package:proy/app_state.dart';
import 'package:proy/screens/address_form_screen.dart';
import 'package:proy/login.dart';
import 'package:mysql1/mysql1.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  bool _isLoadingAddresses = false;
  List<ShippingAddress> _addresses = [];
  ShippingAddress? _selectedAddress;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Credenciales de PayPal Sandbox
  static const String clientId = "AaIqbezTiRngYQanN2k3mSTLf9moIsWL1eBIQ959odA6lCqVaGmG6FX9M2rDbiSCLFjWc-CeOLVWH_Ng";
  static const String secretKey = "ELtSsfFMB612ltTdirxnV0oVqi4xGSGLlKn3gfmYqn6VtVzudAI-bvLBqN_Ci20j3l39qIYmUbNLB5ur";
  static const String returnURL = "https://darkysfishshop.gownetwork.com.mx/return";
  static const String cancelURL = "https://darkysfishshop.gownetwork.com.mx/cancel";

  @override
  void initState() {
    super.initState();
    _loadAddresses();
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

      // Seleccionar la dirección predeterminada si existe
      _selectedAddress = _addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => _addresses.first,
      );

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

  void _navigateToSuccess(CartState cart, Map params, List<Map<String, dynamic>> cartItems, double cartTotal) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => OrderSuccessScreen(
            orderId: DateTime.now().millisecondsSinceEpoch.toString(),
            paymentId: params['paymentId'] ?? '',
            total: cartTotal,
            items: cartItems,
            orderDate: DateTime.now(),
          ),
        ),
        (route) => false,
      );
    });
  }

  Future<void> _saveOrderToDatabase(CartState cart, Map params, ShippingAddress address) async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      
      // 1. Insertar en payments primero para obtener el ID
      var paymentResult = await conn.query(
        '''INSERT INTO payments 
           (currency, user_id, charge_id, payment_channel, amount, order_id, 
            status, payment_type, created_at, updated_at) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())''',
        [
          'MXN',
          Provider.of<AppState>(context, listen: false).userId,
          params['paymentId'],
          'paypal',
          cart.totalAmount,
          '0', // order_id temporal
          'completed',
          'confirm',
        ],
      );

      final paymentId = paymentResult.insertId;
      
      // 2. Insertar en ec_orders
      var orderResult = await conn.query(
        '''INSERT INTO ec_orders 
           (user_id, shipping_option, shipping_method, status, amount, currency_id, 
            tax_amount, shipping_amount, description, sub_total, is_confirmed, 
            is_finished, token, payment_id, discount_amount, created_at, updated_at) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())''',
        [
          Provider.of<AppState>(context, listen: false).userId,
          '2', // shipping_option
          'default', // shipping_method
          'pending', // status
          cart.totalAmount,
          '1', // currency_id (MXN)
          '0.00', // tax_amount
          '0.00', // shipping_amount
          'Orden desde app móvil',
          cart.totalAmount,
          '0', // is_confirmed
          '1', // is_finished
          DateTime.now().millisecondsSinceEpoch.toString(), // token
          paymentId, // ID del pago recién creado
          '0.00', // discount_amount
        ],
      );

      final orderId = orderResult.insertId;

      // 3. Actualizar el order_id en payments
      await conn.query(
        'UPDATE payments SET order_id = ? WHERE id = ?',
        [orderId, paymentId],
      );

      // 4. Insertar en ec_order_addresses
      await conn.query(
        '''INSERT INTO ec_order_addresses 
           (name, phone, email, country, state, city, address, order_id, zip_code) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          address.name,
          address.phone,
          address.email,
          address.country,
          address.state,
          address.city,
          address.address,
          orderId,
          address.zipCode,
        ],
      );

      // 5. Insertar en ec_order_product
      for (var item in cart.items.values) {
        await conn.query(
          '''INSERT INTO ec_order_product 
             (order_id, qty, price, tax_amount, options, product_id, product_name, 
              weight, restock_quantity, created_at, updated_at) 
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())''',
          [
            orderId,
            item.quantity,
            item.price,
            '0.00', // tax_amount
            '[]', // options
            item.id,
            item.name,
            '0.10', // weight
            '0', // restock_quantity
          ],
        );
      }

      print('Orden guardada exitosamente con ID: $orderId y Payment ID: $paymentId');
    } catch (e) {
      print('Error al guardar la orden: $e');
      throw e;
    } finally {
      await conn?.close();
    }
  }

  void _processPaypalPayment(BuildContext context, CartState cart) async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }

    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona una dirección de envío')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Convertir items del carrito al formato de PayPal
    final paypalItems = cart.items.values.map((item) => {
      "name": item.name,
      "quantity": item.quantity,
      "price": item.price.toString(),
      "currency": "MXN"
    }).toList();

    // Guardar los datos del carrito antes de la transacción
    final cartItems = cart.items.values.map((item) => {
      "name": item.name,
      "quantity": item.quantity,
      "price": item.price.toString(),
    }).toList();
    final cartTotal = cart.totalAmount;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
          sandboxMode: true,
          clientId: clientId,
          secretKey: secretKey,
          returnURL: returnURL,
          cancelURL: cancelURL,
          transactions: [{
            "amount": {
              "total": cart.totalAmount.toString(),
              "currency": "MXN",
              "details": {
                "subtotal": cart.totalAmount.toString(),
                "shipping": '0',
                "shipping_discount": 0
              }
            },
            "description": "Pago de productos en Darkys",
            "item_list": {
              "items": paypalItems,
            }
          }],
          note: "Contacta a soporte si tienes problemas con tu pago",
          onSuccess: (Map params) async {
            print("¡Pago exitoso! ${params['paymentId']}");
            try {
              await _saveOrderToDatabase(cart, params, _selectedAddress!);
              cart.clear();
              _navigateToSuccess(cart, params, cartItems, cartTotal);
            } catch (e) {
              print("Error al guardar la orden: $e");
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al guardar la orden. Por favor, contacta a soporte.')),
              );
            }
          },
          onError: (error) {
            print("Error en el pago: $error");
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error en el pago: $error')),
            );
          },
          onCancel: (params) {
            print('Pago cancelado: $params');
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pago cancelado')),
            );
          },
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _isLoading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartState>(context);
    final appState = Provider.of<AppState>(context);
    
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) return false;
        return true;
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Checkout con PayPal',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de dirección de envío
                    Text(
                      'Dirección de envío',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    if (_isLoadingAddresses)
                      Center(child: CircularProgressIndicator())
                    else if (!appState.isLoggedIn)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Debes iniciar sesión para usar direcciones guardadas',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginPage(
                                      returnTo: CheckoutScreen(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text('Iniciar sesión'),
                            ),
                          ],
                        ),
                      )
                    else if (_addresses.isEmpty)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'No tienes direcciones guardadas',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddressFormScreen(),
                                  ),
                                );
                                if (result == true) {
                                  _loadAddresses();
                                }
                              },
                              child: Text('Agregar dirección'),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ..._addresses.map((address) => RadioListTile<ShippingAddress>(
                              value: address,
                              groupValue: _selectedAddress,
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
                              onChanged: (value) {
                                setState(() {
                                  _selectedAddress = value;
                                });
                              },
                            )).toList(),
                            SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddressFormScreen(),
                                  ),
                                );
                                if (result == true) {
                                  _loadAddresses();
                                }
                              },
                              child: Text('Agregar nueva dirección'),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 32),

                    // Resumen del carrito
                    Text(
                      'Resumen del pedido',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Lista de productos
                    ...cart.items.values.map((item) => Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.name}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          Text(
                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                    Divider(height: 32),
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${cart.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    
                    // Información de PayPal
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pago Seguro con PayPal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Serás redirigido a PayPal para completar tu pago de forma segura.',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),

                    // Botón de pago
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _processPaypalPayment(context, cart),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text('Procesando...'),
                                ],
                              )
                            : Text(
                                'Pagar con PayPal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF0070BA),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 