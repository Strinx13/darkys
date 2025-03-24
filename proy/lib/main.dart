import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proy/app_state.dart';
import 'package:proy/models/cart_state.dart';
import 'package:proy/mainScreen.dart';
import 'package:proy/login.dart';
import 'package:proy/more_screen.dart';
import 'package:proy/models/product.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppState()),
        ChangeNotifierProvider(create: (context) => CartState()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainScreen());
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _featuredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
  }

  Future<void> _loadFeaturedProducts() async {
    MySqlConnection? conn;
    try {
      print('Intentando conectar a la base de datos...');
      conn = await DatabaseHelper.connect();
      print('Conexión exitosa, ejecutando consulta...');

      // Primero verificamos si hay productos en general
      var testQuery = await conn.query(
        'SELECT COUNT(*) as total FROM ec_products',
      );
      print('Total de productos en la base de datos: ${testQuery.first[0]}');

      // Ahora la consulta específica
      var results = await conn.query(
        'SELECT id, name, description, images, price, status, quantity, is_featured FROM ec_products WHERE is_featured = 1',
      );

      print('Número de productos encontrados: ${results.length}');
      for (var row in results) {
        print('Producto encontrado:');
        print('  ID: ${row[0]}');
        print('  Nombre: ${row[1]}');
        print('  Images: ${row[3]}');
        print('  Status: ${row[5]}');
        print('  Featured: ${row[7]}');
      }

      setState(() {
        _featuredProducts =
            results.map((row) {
              String imageUrl = row[3].toString();
              // Limpiamos la URL de caracteres especiales y formato JSON
              imageUrl =
                  imageUrl
                      .replaceAll('[', '')
                      .replaceAll(']', '')
                      .replaceAll('"', '')
                      .trim();

              // Asegurarnos de que la URL sea absoluta
              if (!imageUrl.startsWith('http')) {
                imageUrl =
                    'https://darkysfishshop.gownetwork.com.mx/storage/' +
                    imageUrl;
              }

              print('URL procesada: $imageUrl'); // Debug log

              return Product.fromMap({
                'id': row[0],
                'name': row[1],
                'description': row[2],
                'images': imageUrl,
                'price': row[4],
                'status': row[5],
                'quantity': row[6],
                'is_featured': row[7],
              });
            }).toList();
        print('Productos cargados en el estado: ${_featuredProducts.length}');
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error al cargar productos destacados:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    } finally {
      await conn?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Darky´s',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(appState.isLoggedIn ? Icons.person : Icons.login),
            onPressed: () {
              if (appState.isLoggedIn) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MoreScreen()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
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
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
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
                      Text(
                        "Descuentos",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Categorías",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: Text("Ver todo")),
              ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    ["Todos", "Bettas", "Guppys", "Plecos", "Alimentos"]
                        .map(
                          (category) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Chip(label: Text(category)),
                          ),
                        )
                        .toList(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Productos Destacados',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_featuredProducts.isEmpty)
              Center(child: Text('No hay productos destacados disponibles'))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = _featuredProducts[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            product.images,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error cargando imagen: $error');
                              return Container(
                                height: 120,
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Error al cargar imagen',
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 120,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      product.quantity > 0
                                          ? 'En stock'
                                          : 'Agotado',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            product.quantity > 0
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.add_shopping_cart,
                                        size: 20,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      onPressed:
                                          product.quantity > 0
                                              ? () {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Producto agregado al carrito',
                                                    ),
                                                  ),
                                                );
                                              }
                                              : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
