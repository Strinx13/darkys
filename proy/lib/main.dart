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
import 'dart:async';
import 'package:proy/catalog.dart';
import 'package:proy/product.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
  bool _isLoading = true;
  List<Product> _featuredProducts = [];
  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFeaturedProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      var results = await conn.query(
        'SELECT id, name FROM ec_product_categories WHERE status = ? AND parent_id = 0 ORDER BY `order`',
        ['published'],
      );

      setState(() {
        _categories = results
            .map((row) => {
                  'id': row['id'],
                  'name': row['name'],
                })
            .toList();

        // Agregar categoría "Todos"
        _categories.insert(0, {'id': '0', 'name': 'Todos'});
        _selectedCategory = '0';
      });
    } catch (e) {
      print('Error al cargar categorías: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<void> _loadFeaturedProducts() async {
    setState(() {
      _isLoading = true;
    });

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();

      String query;
      List<Object> params;

      if (_selectedCategory == '0' || _selectedCategory == null) {
        query = '''
          SELECT p.id, p.name, p.description, p.images, p.price, p.status, p.quantity, p.is_featured
          FROM ec_products p
          WHERE p.status = ? AND p.is_featured = 1
          ${_searchQuery.isNotEmpty ? 'AND p.name LIKE ?' : ''}
        ''';
        params = ['published'];
        if (_searchQuery.isNotEmpty) {
          params.add('%$_searchQuery%');
        }
      } else {
        query = '''
          SELECT DISTINCT p.id, p.name, p.description, p.images, p.price, p.status, p.quantity, p.is_featured
          FROM ec_products p
          INNER JOIN ec_product_category_product cp ON p.id = cp.product_id
          WHERE p.status = ? AND cp.category_id = ? AND p.is_featured = 1
          ${_searchQuery.isNotEmpty ? 'AND p.name LIKE ?' : ''}
        ''';
        params = ['published', int.parse(_selectedCategory!)];
        if (_searchQuery.isNotEmpty) {
          params.add('%$_searchQuery%');
        }
      }

      var results = await conn.query(query, params);

      setState(() {
        _featuredProducts = results.map((row) {
          String imageUrl = row[3].toString();
          imageUrl = imageUrl
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('"', '')
              .trim();

          if (!imageUrl.startsWith('http')) {
            imageUrl =
                'https://darkysfishshop.gownetwork.com.mx/storage/' + imageUrl;
          }

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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchQuery != query) {
        setState(() {
          _searchQuery = query;
        });
        _loadFeaturedProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Darky´s Fish Shop',
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de búsqueda
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Buscar productos...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              // Carrusel
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  aspectRatio: 16/9,
                  viewportFraction: 0.9,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                ),
                items: [
                  _buildCarouselItem(
                    'https://darkysfishshop.gownetwork.com.mx/storage/guppyd/476440798-1852734632209858-1377388764678931715-n.jpg',
                    'Peces Betta',
                    'Los más hermosos especímenes',
                    Colors.indigo.shade700,
                    isNetworkImage: true,
                  ),
                  _buildCarouselItem(
                    'https://darkysfishshop.gownetwork.com.mx/storage/guppyd/imagen-de-whatsapp-2025-01-29-a-las-090020-b452c174.jpg',
                    'Peces Guppy',
                    'Variedad de colores',
                    Colors.blue.shade700,
                    isNetworkImage: true,
                  ),
                  _buildCarouselItem(
                    'https://darkysfishshop.gownetwork.com.mx/storage/guppyd/acuario-en-casa-iluminacion.jpg',
                    'Acuarios',
                    'Todo para tu pecera',
                    Colors.teal.shade700,
                    isNetworkImage: true,
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Categorías",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CatalogScreen()),
                        );
                      },
                      child: Text("Ver todo"),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    final isSelected =
                        category['id'].toString() == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(category['name']),
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedCategory = category['id'].toString();
                            _loadFeaturedProducts();
                          });
                        },
                        selectedColor: Colors.red[100],
                        checkmarkColor: Colors.red,
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 20),
              Text(
                _selectedCategory == '0'
                    ? ' Productos Destacados'
                    : _categories.any((cat) =>
                            cat['id'].toString() == _selectedCategory)
                        ? 'Productos Destacados en ${_categories.firstWhere((cat) => cat['id'].toString() == _selectedCategory)['name']}'
                        : 'Productos Destacados',
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
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductScreen(product: product),
                                  ),
                                );
                              },
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                              ),
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
                                            : 'Bajo pedido',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: product.quantity > 0
                                              ? Colors.green
                                              : Colors.orange,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_shopping_cart,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                        onPressed: () {
                                          final cart = Provider.of<CartState>(
                                            context,
                                            listen: false,
                                          );
                                          cart.addItem(
                                            product.id,
                                            product.name,
                                            product.price,
                                            product.images,
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Producto agregado al carrito',
                                              ),
                                              duration: Duration(seconds: 2),
                                              action: SnackBarAction(
                                                label: 'Ver Carrito',
                                                onPressed: () {
                                                  Navigator.pushNamed(
                                                      context, '/cart');
                                                },
                                              ),
                                            ),
                                          );
                                        },
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
      ),
    );
  }

  Widget _buildCarouselItem(String imagePath, String title, String subtitle, Color color, {bool isNetworkImage = false}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 2),
            blurRadius: 6.0,
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: isNetworkImage
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error cargando imagen del carrusel: $error');
                      return Container(
                        color: color,
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: color,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        blurRadius: 8.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
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
