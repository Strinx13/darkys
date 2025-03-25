import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:proy/db_connection.dart';
import 'package:provider/provider.dart';
import 'package:proy/models/cart_state.dart';
import 'package:proy/models/product.dart';
import 'package:proy/product.dart';
import 'package:proy/mainScreen.dart';
import 'dart:async';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String? selectedCategory;
  bool _isLoading = true;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> categories = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
        categories = results
            .map((row) => {
                  'id': row['id'],
                  'name': row['name'],
                })
            .toList();

        // Agregar categoría "Todos"
        categories.insert(0, {'id': '0', 'name': 'Todos'});

        selectedCategory = '0';
        _loadProducts();
      });
    } catch (e) {
      print('Error al cargar categorías: $e');
    } finally {
      await conn?.close();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    MySqlConnection? conn;
    try {
      conn = await DatabaseHelper.connect();
      String query;
      List<Object> params;

      if (selectedCategory == '0') {
        query = '''
          SELECT DISTINCT p.id, p.name, p.price, p.images, p.status, p.quantity, p.description 
          FROM ec_products p
          WHERE p.status = ?
          ${_searchQuery.isNotEmpty ? 'AND p.name LIKE ?' : ''}
        ''';
        params = ['published'];
      } else {
        query = '''
          SELECT DISTINCT p.id, p.name, p.price, p.images, p.status, p.quantity, p.description 
          FROM ec_products p
          INNER JOIN ec_product_category_product cp ON p.id = cp.product_id
          WHERE p.status = ? AND cp.category_id = ?
          ${_searchQuery.isNotEmpty ? 'AND p.name LIKE ?' : ''}
        ''';
        params = ['published', int.parse(selectedCategory!)];
      }

      if (_searchQuery.isNotEmpty) {
        params.add('%$_searchQuery%');
      }

      var results = await conn.query(query, params);

      setState(() {
        products = results.map((row) {
          String imageUrl = row['images'].toString();
          if (!imageUrl.startsWith('http')) {
            imageUrl = 'https://darkysfishshop.gownetwork.com.mx/storage/' +
                imageUrl
                    .replaceAll('[', '')
                    .replaceAll(']', '')
                    .replaceAll('"', '');
          }

          return {
            'id': row['id'],
            'title': row['name'],
            'price': row['price'],
            'time': row['quantity'] > 0 ? 'En stock' : 'Bajo pedido',
            'image': imageUrl,
            'rating': 5.0,
            'isFavorite': false,
            'quantity': row['quantity'],
            'description': row['description'] ?? '',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar productos: $e');
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
        _loadProducts();
      }
    });
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
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(initialIndex: 0)),
              );
            }
          },
        ),
        title: Text(
          'Catálogo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Categorías
          Container(
            height: 50,
            margin: EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected =
                    category['id'].toString() == selectedCategory;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category['id'].toString();
                      _loadProducts();
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected ? Colors.red : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Título de la sección
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Productos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Lista de productos
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? Center(child: Text('No hay productos disponibles'))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Imagen del producto
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductScreen(
                                            product: Product.fromMap({
                                              'id': product['id'],
                                              'name': product['title'],
                                              'description':
                                                  product['description'],
                                              'images': product['image'],
                                              'price': product['price'],
                                              'status': 'published',
                                              'quantity': int.parse(
                                                  product['quantity']
                                                      .toString()),
                                              'is_featured': 0,
                                            }),
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        product['image'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                            ),
                                          );
                                        },
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
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
                                  ),
                                ),
                                // Información del producto
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['title'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                            Text(
                                              ' ${product['rating']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              color: Colors.grey[600],
                                              size: 18,
                                            ),
                                            Text(
                                              ' ${product['time']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '\$${product['price'].toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                product['isFavorite']
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: product['isFavorite']
                                                    ? Colors.red
                                                    : Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  product['isFavorite'] =
                                                      !product['isFavorite'];
                                                });
                                              },
                                            ),
                                            IconButton(
                                              icon:
                                                  Icon(Icons.add_shopping_cart),
                                              onPressed: () {
                                                final cart =
                                                    Provider.of<CartState>(
                                                  context,
                                                  listen: false,
                                                );
                                                cart.addItem(
                                                  product['id'],
                                                  product['title'],
                                                  product['price'],
                                                  product['image'],
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Producto agregado al carrito',
                                                    ),
                                                    duration: Duration(
                                                      seconds: 2,
                                                    ),
                                                    action: SnackBarAction(
                                                      label: 'Ver Carrito',
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/cart',
                                                        );
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
          ),
        ],
      ),
    );
  }
}
