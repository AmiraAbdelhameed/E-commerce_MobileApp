import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<CartScreen> {
  late Future<List<Map<String, dynamic>>> _cartItemsFuture;

  @override
  void initState() {
    super.initState();
    _cartItemsFuture = getCartProducts();
  }

  Future<List<Map<String, dynamic>>> getCartProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productStrings = prefs.getStringList('cart') ?? [];
      return productStrings
          .map((item) => jsonDecode(item) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  Future<void> confirmOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final cartItems = prefs.getStringList('cart') ?? [];
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Your cart is empty!')));
      return;
    }
    final existingOrders = prefs.getStringList('orders') ?? [];
    existingOrders.addAll(cartItems);
    await prefs.setStringList('orders', existingOrders);
    await prefs.remove('cart');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Confirmed!'),
          content: Text('Your order has been placed successfully.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _cartItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading cart'));
                  }
                  final cartItems = snapshot.data ?? [];
                  if (cartItems.isEmpty) {
                    return Center(child: Text('Your cart is empty'));
                  }
                  return ListView.builder(
                    padding: EdgeInsets.all(8),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final product = cartItems[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: SizedBox(
                          width: 500,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Image.network(
                                  product['image'].toString(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              SizedBox(width: 50),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    '\$${product['price']?.toString() ?? 'N/A'}',
                                  ),
                                  SizedBox(width: 10),
                                  Text("Quantity: 1"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                confirmOrder();
              },

              child: Text("Confirm Order"),
            ),
          ],
        ),
      ),
    );
  }
}
