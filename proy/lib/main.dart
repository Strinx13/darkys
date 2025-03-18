import 'package:flutter/material.dart';
import 'package:proy/mainScreen.dart';
import 'login.dart';
import 'product.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Darky´s', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.verified_user),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra de búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),

            // Sección de "Descuentos"
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF77272),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Descuentos", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Hasta 50%", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/full.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Categorías
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Categorías", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text("Ver todo")),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Todos", "Bettas", "Guppys", "Plecos", "Alimentos"]
                    .map((category) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Chip(label: Text(category)),
                        ))
                    .toList(),
              ),
            ),
            SizedBox(height: 20),

            // Productos en cuadrícula
            GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 4, // Puedes reemplazar con el total de productos
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductScreen(),
          ),
        );
      },
      child: ProductCard(
        title: index % 2 == 0 ? "Guppy Metal Red Lace" : "Guppy Koi Red Ears",
        price: index % 2 == 0 ? "\$132.00" : "\$1100.00",
        imageUrl: "assets/Metal.jpg",
        inStock: index % 2 == 0, // Alternar stock
      ),
    );
  },
),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favoritos"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }
}

// Tarjeta de Producto con stock
class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final bool inStock;

  ProductCard({required this.title, required this.price, required this.imageUrl, required this.inStock});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              imageUrl,
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                
                SizedBox(height: 8),

                // Precio
                Text(price, style: TextStyle(color: Colors.red, fontSize: 16)),

                SizedBox(height: 0),

                // Botón de Stock
                Container(
                  width: 120, 
                  height: 20, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: inStock ? const Color.fromARGB(255, 157, 199, 158) : const Color.fromARGB(255, 236, 132, 125),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: Text(inStock ? "En Stock" : "Agotado"),
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
