import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProductScreen(),
    );
  }
}

class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // Imagen del producto
          Container(
            height: 300,
            child: PageView(
              children: [
                Image.asset('assets/Koi.jpg', fit: BoxFit.cover),
                Image.asset('assets/Koi.jpg', fit: BoxFit.cover),
              ],
            ),
          ),
                    
          // Detalles del producto
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Shopping",
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "AKG N700NCM2",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Hi-Fi Shop & Service Rustaveli Ave 57.\nThis shop offers both products and services",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 10),
                  
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 5),
                      Text("Rustaveli Ave 57, 17-001, Batumi"),
                    ],
                  ),

                  SizedBox(height: 20),
                  
                  Text(
                    "\$199.00",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Tax Rate 2% - \$4.00 (~\$195.00)",
                    style: TextStyle(color: Colors.grey[600]),
                  ),

                  Spacer(),

                  // Botón de compra
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "ADD TO CART",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
