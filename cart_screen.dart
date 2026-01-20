import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_shop/main.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Stream<List<Map<String, dynamic>>>? _cartStream;

  @override
  void initState() {
    super.initState();
    final user = supabase.auth.currentUser;
    if (user != null) {
      _cartStream = supabase
          .from('cart')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cartStream == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view cart')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _cartStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final cartItems = snapshot.data!;
          if (cartItems.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return CartItemWidget(item: item);
                  },
                ),
              ),
              CartTotal(cartItems: cartItems),
            ],
          );
        },
      ),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;

  const CartItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostgrestMap>(
      future: supabase
          .from('products')
          .select()
          .eq('id', item['product_id'])
          .single(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(
            title: Text('Loading...'),
            leading: CircularProgressIndicator(),
          );
        }
        final product = snapshot.data!;
        final quantity = item['quantity'] as int;
        final price = product['price'] as num;
        final total = price * quantity;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: product['image_url'] != null
                ? Image.network(product['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(product['name']),
            subtitle: Text('Qty: $quantity x \$$price = \$${total.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await supabase.from('cart').delete().eq('id', item['id']);
              },
            ),
          ),
        );
      },
    );
  }
}

class CartTotal extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartTotal({super.key, required this.cartItems});

  Future<double> _calculateTotal() async {
    double total = 0;
    for (var item in cartItems) {
      final response = await supabase
          .from('products')
          .select('price')
          .eq('id', item['product_id'])
          .single();
      final price = response['price'] as num;
      total += price * (item['quantity'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: FutureBuilder<double>(
        future: _calculateTotal(),
        builder: (context, snapshot) {
          final total = snapshot.data ?? 0.0;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: \$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checkout functionality coming soon!')),
                  );
                },
                child: const Text('Checkout'),
              ),
            ],
          );
        },
      ),
    );
  }
}
