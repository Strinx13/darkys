import 'package:flutter/material.dart';
import 'product.dart'; // Asegúrate de que este archivo tenga la definición de la pantalla de detalles de producto.

class CatalogScreen extends StatelessWidget {
  // Lista de productos (puedes agregar más productos según sea necesario)
  final List<Map<String, String>> products = [
    {
      'title': 'Guppy Metal Red Lace',
      'price': '\$132.00',
      'image': 'assets/Metal.jpg',
    },
    {
      'title': 'Guppy Koi Red Ears',
      'price': '\$1100.00',
      'image': 'assets/Metal.jpg',
    },
    {
      'title': 'Betta Blue Dragon',
      'price': '\$200.00',
      'image': 'assets/Metal.jpg',
    },
    {
      'title': 'Pleco Albino',
      'price': '\$150.00',
      'image': 'assets/Metal.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Productos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return GestureDetector(
            onTap: () {
              // Navegar a la página de detalles del producto
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductScreen(),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.asset(
                      product['image']!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['title']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text(
                          product['price']!,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
