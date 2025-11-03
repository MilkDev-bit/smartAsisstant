import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'product_service.dart';
import '../cart/cart_service.dart';
import '../cart/cart_screen.dart';
import 'product_model.dart';
import '../orders/order_history_screen.dart';
import '../../core/api_service.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProducts();
    });
  }

  Future<void> _fetchProducts() async {
    final service = Provider.of<ProductService>(context, listen: false);
    await service.fetchProducts();
    if (mounted && service.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${service.error}'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final cartService = Provider.of<CartService>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tienda de Hamburguesas',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4AF37), Color(0xFFF4E5B8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined,
                      color: Colors.white),
                  tooltip: 'Ver Carrito',
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()));
                  },
                ),
              ),
              if (cartService.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${cartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF4E5B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon:
                  const Icon(Icons.receipt_long_outlined, color: Colors.white),
              tooltip: 'Mis Pedidos',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFF4E5B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'Actualizar',
              onPressed: productService.isLoading ? null : _fetchProducts,
            ),
          ),
        ],
      ),
      body: _buildProductList(context, productService),
    );
  }

  Widget _buildProductList(BuildContext context, ProductService service) {
    if (service.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
        ),
      );
    }
    if (service.error != null && service.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Error: ${service.error}',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      );
    }
    if (service.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No hay productos disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve más tarde',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final baseUrl =
        Provider.of<ApiService>(context, listen: false).dio.options.baseUrl;

    return RefreshIndicator(
      color: const Color(0xFFD4AF37),
      onRefresh: _fetchProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.95,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: service.products.length,
        itemBuilder: (ctx, i) =>
            _ProductItemCard(product: service.products[i], baseUrl: baseUrl),
      ),
    );
  }
}

class _ProductItemCard extends StatelessWidget {
  final Product product;
  final String baseUrl;
  const _ProductItemCard({required this.product, required this.baseUrl});

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);
    final quantityInCart = cartService.getQuantity(product.id);
    final imageUrl =
        product.imageUrl != null ? '$baseUrl${product.imageUrl}' : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 25),
                    )
                  : Icon(Icons.fastfood, size: 25, color: Colors.grey[400]),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.nombre,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 0),
                      Text(
                        product.descripcion,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[600],
                          height: 1.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_money,
                              size: 9, color: Color(0xFFD4AF37)),
                          Text(
                            '${product.precio.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              fontSize: 7,
                              color: product.stock > 0
                                  ? Colors.grey[600]
                                  : Colors.red,
                              fontWeight: product.stock > 0
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                  quantityInCart == 0
                      ? _buildAddButton(context, cartService)
                      : _buildQuantityControls(
                          context, cartService, quantityInCart),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, CartService cartService) {
    final isOutOfStock = product.stock <= 0;

    return SizedBox(
      height: 26,
      child: Material(
        borderRadius: BorderRadius.circular(5),
        color: isOutOfStock ? Colors.grey[400] : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: isOutOfStock
              ? null
              : () {
                  cartService.addItem(product);
                  _showSnackBar(context, '${product.nombre} añadido al carrito',
                      Colors.green);
                },
          child: Container(
            decoration: isOutOfStock
                ? null
                : BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFF4E5B8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isOutOfStock ? Icons.block : Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 10,
                  ),
                  const SizedBox(width: 1),
                  Text(
                    isOutOfStock ? 'Sin Stock' : 'Añadir',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityControls(
      BuildContext context, CartService cartService, int quantity) {
    final canAddMore = quantity < product.stock;

    return SizedBox(
      height: 26,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Material(
                borderRadius: BorderRadius.circular(4),
                color: Colors.red[50],
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    cartService.removeSingleItem(product.id);
                    if (quantity == 1) {
                      _showSnackBar(
                          context,
                          '${product.nombre} removido del carrito',
                          Colors.orange);
                    }
                  },
                  child: const Icon(Icons.remove, size: 10, color: Colors.red),
                ),
              ),
            ),
            Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(
              width: 22,
              height: 22,
              child: Material(
                borderRadius: BorderRadius.circular(4),
                color: canAddMore ? Colors.green[50] : Colors.grey[200],
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: canAddMore ? () => cartService.addItem(product) : null,
                  child: Icon(Icons.add,
                      size: 10, color: canAddMore ? Colors.green : Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
