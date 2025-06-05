import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'productDetails_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  @override
  _CategoryProductsState createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProductsScreen> {
  String category = '';

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      category = prefs.getString('category') ?? '';
    });
  }

  Future<List<Map>> fetchProducts() async {
    if (category.isNotEmpty) {
      final url = Uri.parse(
        "https://ib.jamalmoallart.com/api/v1/products/category/$category",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map<Map>((product) => product).toList();
      } else {
        throw Exception("Falid to load products");
      }
    } else {
      final url = Uri.parse("https://ib.jamalmoallart.com/api/v1/all/products");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map<Map>((product) => product).toList();
      } else {
        throw Exception("Falid to load products");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(category),
            FutureBuilder(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Products here .."));
                } else {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      return Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            Expanded(child: Image.network(product['image'])),
                            Text(product["name"]),
                            Text(product["description"]),
                            Text('Price: \$${product["price"]}'),
                            ElevatedButton(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                // Convert product map to a JSON string
                                await prefs.setString(
                                  'product',
                                  jsonEncode(product),
                                );
                                print(prefs.getString('product') ?? '');

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductdetailsScreen(),
                                  ),
                                );
                              },
                              child: Text("View Product"),
                            ),

                             ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
