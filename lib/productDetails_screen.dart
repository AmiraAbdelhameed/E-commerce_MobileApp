import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductdetailsScreen extends StatefulWidget {
  @override
  _ProductdetailsState createState() => _ProductdetailsState();
}

class _ProductdetailsState extends State<ProductdetailsScreen> {
  Map<String, dynamic>? product;

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  Future<void> loadProduct() async {
    final prefs = await SharedPreferences.getInstance();
    final productString = prefs.getString('product');
    if (productString != null) {
      setState(() {
        product = jsonDecode(productString);
      });
    }
  }

  Future<void> addProductToCart(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final existingList = prefs.getStringList('cart') ?? [];
    final productJson = jsonEncode(product);
    existingList.add(productJson);
    await prefs.setStringList('cart', existingList);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: const Text('Your Info'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text("product added to cart ")]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
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
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Product Details")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product!["name"])),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(product!["image"]),
              SizedBox(height: 10),
              Text(
                product!["name"],
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(product!["description"]),
              SizedBox(height: 10),
              Text(
                'Price: \$${product!["price"]}',
                style: TextStyle(fontSize: 18),
              ),
              ElevatedButton(
                onPressed: () async {
                  addProductToCart(product!);
                },
                child: Text("Add to cart"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
