import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  OrderDetailScreen({required this.orderId});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderData;
  List<Map<String, dynamic>> _orderProducts = [];

  @override
  void initState() {
    super.initState();
    _loadOrderDetails();
  }

  Future<void> _loadOrderDetails() async {
    setState(() => _isLoading = true);

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      
      // Obtener detalles de la orden
      var orderResults = await conn.query('''
        SELECT 
          o.id,
          o.amount,
          CONVERT(o.status USING utf8) as status,
          o.created_at,
          CONVERT(p.payment_channel USING utf8) as payment_channel,
          CONVERT(p.status USING utf8) as payment_status,
          o.shipping_amount,
          CONVERT(a.name USING utf8) as customer_name,
          CONVERT(a.phone USING utf8) as phone,
          CONVERT(a.email USING utf8) as email,
          CONVERT(a.address USING utf8) as address,
          CONVERT(a.city USING utf8) as city,
          CONVERT(a.state USING utf8) as state,
          CONVERT(a.country USING utf8) as country,
          CONVERT(o.description USING utf8) as description
        FROM ec_orders o
        LEFT JOIN payments p ON o.payment_id = p.id
        LEFT JOIN ec_order_addresses a ON o.id = a.order_id
        WHERE o.id = ?
      ''', [widget.orderId]);

      if (orderResults.isNotEmpty) {
        var row = orderResults.first;
        
        String convertBlobToString(dynamic value) {
          if (value == null) return 'N/A';
          if (value is Blob) {
            return String.fromCharCodes(value.toBytes());
          }
          return value.toString();
        }

        _orderData = {
          'id': row['id'],
          'amount': (row['amount'] as double?)?.toDouble() ?? 0.0,
          'status': convertBlobToString(row['status']),
          'created_at': row['created_at'] as DateTime,
          'payment_channel': convertBlobToString(row['payment_channel']),
          'payment_status': convertBlobToString(row['payment_status']),
          'shipping_amount': (row['shipping_amount'] as double?)?.toDouble() ?? 0.0,
          'customer_name': convertBlobToString(row['customer_name']),
          'phone': convertBlobToString(row['phone']),
          'email': convertBlobToString(row['email']),
          'address': convertBlobToString(row['address']),
          'city': convertBlobToString(row['city']),
          'state': convertBlobToString(row['state']),
          'country': convertBlobToString(row['country']),
          'description': convertBlobToString(row['description']),
        };

        // Obtener productos de la orden
        var productResults = await conn.query('''
          SELECT 
            id,
            CONVERT(product_name USING utf8) as product_name,
            qty,
            price
          FROM ec_order_product
          WHERE order_id = ?
        ''', [widget.orderId]);

        _orderProducts = productResults.map((row) {
          return {
            'product_name': convertBlobToString(row['product_name']),
            'qty': row['qty'] as int,
            'price': (row['price'] as double?)?.toDouble() ?? 0.0,
          };
        }).toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error al cargar detalles de la orden: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los detalles de la orden')),
      );
      setState(() => _isLoading = false);
    } finally {
      await conn?.close();
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
          'Información de Orden',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orderData == null
              ? Center(child: Text('No se encontró la orden'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoSection(
                        'Información de Orden',
                        [
                          _buildInfoRow('Numero de Orden', '#${widget.orderId.toString().padLeft(8, '0')}'),
                          _buildInfoRow('Fecha', _formatDate(_orderData!['created_at'])),
                          _buildInfoRow('Status de la orden', _orderData!['status'], 
                            valueColor: _orderData!['status'].toString().toLowerCase() == 'pending' 
                              ? Colors.orange 
                              : Colors.green),
                          _buildInfoRow('Método de pago', _orderData!['payment_channel'] ?? 'N/A'),
                          _buildInfoRow('Estatus del Pago', _orderData!['payment_status'] ?? 'N/A',
                            valueColor: _orderData!['payment_status'] == 'completed' ? Colors.green : Colors.orange),
                          _buildInfoRow('Precio', '\$${_orderData!['amount'].toStringAsFixed(2)}'),
                          _buildInfoRow('Gastos de Envío', '\$${_orderData!['shipping_amount'].toStringAsFixed(2)}'),
                          if (_orderData!['description'] != null)
                            _buildInfoRow('Nota', _orderData!['description']),
                        ],
                      ),
                      _buildInfoSection(
                        'Información del cliente',
                        [
                          _buildInfoRow('Nombre Completo', _orderData!['customer_name']),
                          _buildInfoRow('Teléfono', _orderData!['phone']),
                          _buildInfoRow('Email', _orderData!['email']),
                          _buildInfoRow('Dirección', _orderData!['address']),
                          _buildInfoRow('Ciudad', _orderData!['city']),
                          _buildInfoRow('Estado', _orderData!['state']),
                          _buildInfoRow('País', _orderData!['country']),
                        ],
                      ),
                      _buildInfoSection(
                        'Detalle de Orden',
                        [
                          Table(
                            columnWidths: {
                              0: FlexColumnWidth(0.5),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Producto', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Precio', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              ...List.generate(_orderProducts.length, (index) {
                                final product = _orderProducts[index];
                                final total = (product['price'] as double) * (product['qty'] as int);
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text('${index + 1}'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text(product['product_name']),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text('\$${product['price'].toStringAsFixed(2)}'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text('${product['qty']}'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text('\$${total.toStringAsFixed(2)}'),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
} 