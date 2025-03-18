import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [
    {
      'title': 'Guppy Metal Red Lace',
      'price': 132.00,
      'quantity': 1,
      'image': 'assets/Metal.jpg',
    },
    {
      'title': 'Guppy Koi Red Ears',
      'price': 1100.00,
      'quantity': 2,
      'image': 'assets/Metal.jpg',
    },
  ];

  double getTotalPrice() {
    return cartItems.fold(
      0, (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  void updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]['quantity'] += change;
      if (cartItems[index]['quantity'] <= 0) {
        cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Carrito de Compras')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: ListTile(
                    leading: Image.asset(item['image'], width: 50, height: 50),
                    title: Text(item['title']),
                    subtitle: Text("\$${item['price'].toStringAsFixed(2)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () => updateQuantity(index, -1),
                        ),
                        Text('${item['quantity']}'),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () => updateQuantity(index, 1),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                Text(
                  "Total: \$${getTotalPrice().toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Compra realizada con éxito')),
                    );
                  },
                  child: Text('Finalizar Compra'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
