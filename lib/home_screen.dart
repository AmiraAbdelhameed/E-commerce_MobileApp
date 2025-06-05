import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'category_screen.dart';
import 'productDetails_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController = PageController();
    Map<String, dynamic>? _userData;

  void _onPageChanged(index) {
    print("page ${index}");
    setState(() {
      
    });
  }
  Future<Map<String, dynamic>?> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('LoginUser');
    if (userString != null) {
      setState(() {
        _userData = jsonDecode(userString);
      });
    }
    return null;
  }
  Future<List<String>> fetchCategories() async {
    final url = Uri.parse("https://ib.jamalmoallart.com/api/v1/all/categories");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<String>((category) => category).toList();
    } else {
      throw Exception("Falid to load categories");
    }
  }

  Future<List<Map>> fetchProducts() async {
    final url = Uri.parse("https://ib.jamalmoallart.com/api/v1/all/products");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map<Map>((product) => product).toList();
    } else {
      throw Exception("Falid to load products");
    }
  }
  @override
  void initState() {
    super.initState();
    loadUserData();
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child:  _userData == null
          ?  Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome  Guest " ,style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
            SizedBox(height: 20),
            Center(
              child: Text("Categories" , style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),),
            ),
           
            SizedBox(height: 20),
            FutureBuilder<List<String>>(
              future: fetchCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Categories here .."));
                } else {
                  return SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final category = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('category', category);
                              print(prefs.getString('category') ?? '');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CategoryProductsScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(category)),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            SizedBox(
              height: 180,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  Image.network(
                    "https://images.unsplash.com/photo-1580828343064-fde4fc206bc6?q=80&w=1471&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    fit: BoxFit.cover,
                  ),
                  Image.network(
                    "https://plus.unsplash.com/premium_photo-1671076131210-5376fccb100b?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    fit: BoxFit.cover,
                  ),
                  Image.network(
                    "https://plus.unsplash.com/premium_photo-1670509045675-af9f249b1bbe?q=80&w=1435&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
              Center(
              child: Text(
                "Products",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Repois here .."));
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
      )
    
          : Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome ${_userData!['first_name'] ?? "Guest "}" ,style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),),
            SizedBox(height: 20),
            Center(
              child: Text("Categories" , style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),),
            ),
           
            SizedBox(height: 20),
            FutureBuilder<List<String>>(
              future: fetchCategories(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Categories here .."));
                } else {
                  return SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final category = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('category', category);
                              print(prefs.getString('category') ?? '');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CategoryProductsScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(child: Text(category)),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
            SizedBox(
              height: 180,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  Image.network(
                    "https://images.unsplash.com/photo-1580828343064-fde4fc206bc6?q=80&w=1471&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    fit: BoxFit.cover,
                  ),
                  Image.network(
                    "https://plus.unsplash.com/premium_photo-1671076131210-5376fccb100b?q=80&w=1400&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    fit: BoxFit.cover,
                  ),
                  Image.network(
                    "https://plus.unsplash.com/premium_photo-1670509045675-af9f249b1bbe?q=80&w=1435&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
              Center(
              child: Text(
                "Products",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
              future: fetchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No Repois here .."));
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
