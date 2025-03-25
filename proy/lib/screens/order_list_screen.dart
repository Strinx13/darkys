import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:provider/provider.dart';
import 'package:proy/app_state.dart';
import 'package:proy/db_connection.dart';
import 'package:intl/intl.dart';
import 'package:proy/screens/order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isLoggedIn) return;

    setState(() => _isLoading = true);

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      
      var results = await conn.query('''
        SELECT 
          o.id,
          o.amount,
          o.status,
          o.created_at,
          p.payment_channel,
          p.status as payment_status,
          GROUP_CONCAT(CONVERT(op.product_name USING utf8) SEPARATOR ', ') as products
        FROM ec_orders o
        LEFT JOIN payments p ON o.payment_id = p.id
        LEFT JOIN ec_order_product op ON o.id = op.order_id
        WHERE o.user_id = ?
        GROUP BY o.id
        ORDER BY o.created_at DESC
      ''', [appState.userId]);

      _orders = results.map((row) {
        // Convertir explícitamente los tipos de datos
        String? products;
        if (row['products'] != null) {
          if (row['products'] is Blob) {
            products = String.fromCharCodes((row['products'] as Blob).toBytes());
          } else {
            products = row['products'].toString();
          }
        }

        return {
          'id': row['id'] as int,
          'amount': (row['amount'] as double?)?.toDouble() ?? 0.0,
          'status': (row['status'] as String?) ?? 'pending',
          'created_at': row['created_at'] as DateTime,
          'payment_channel': (row['payment_channel'] as String?) ?? 'N/A',
          'payment_status': (row['payment_status'] as String?) ?? 'N/A',
          'products': products ?? '',
        };
      }).toList();

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error al cargar órdenes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las órdenes')),
      );
      setState(() => _isLoading = false);
    } finally {
      await conn?.close();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'delivering':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatOrderId(int id) {
    return '#' + id.toString().padLeft(8, '0');
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
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
          'Mis Órdenes',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No tienes órdenes aún',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailScreen(
                                orderId: order['id'],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatOrderId(order['id']),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order['status'])
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      order['status'],
                                      style: TextStyle(
                                        color: _getStatusColor(order['status']),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                _formatDate(order['created_at']),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Total: \$${order['amount'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (order['products'] != null) ...[
                                SizedBox(height: 8),
                                Text(
                                  order['products'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    order['payment_channel']?.toUpperCase() ?? 'N/A',
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
                      ),
                    );
                  },
                ),
    );
  }
} 