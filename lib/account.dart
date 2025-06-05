import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_screen.dart';

class User {
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String email;
  final String createdAt;
  final String token;

  User({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.address,
    required this.email,
    required this.createdAt,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      address: json['address'],
      email: json['email'],
      createdAt: json['created_at'],
      token: json['token'],
    );
  }
}

class AccountPage extends StatefulWidget {
  AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // late Future<Map<String, dynamic>> _profileFuture;
  Map<String, dynamic>? _userData;
  final token = "";
  @override
  void initState() {
    super.initState();
    loadUserData();
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
  Future<Map<String, dynamic>?> logout() async {
    final prefs = await SharedPreferences.getInstance();
     prefs.remove('LoginUser');
     return null;
   
  }
  // Future<Map<String, dynamic>> fetchProfile(token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   token = prefs.getString('token');
  //   print(token);

  //   if (token == null || token.isEmpty) {
  //     throw Exception("No token found. Please log in again.");
  //   }

  //   final url = Uri.parse('https://ib.jamalmoallart.com/api/v2/profile');
  //   final response = await http.get(
  //     url,
  //     headers: {"Content-Type": "application/json"},
  //   );

  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     if (data['state'] == true) {
  //       return data['data'];
  //     } else {
  //       throw Exception(data['message'] ?? "Failed to fetch profile");
  //     }
  //   } else {
  //     throw Exception("Server error: ${response.statusCode}");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Page')),
      body:  _userData == null
          ? Center(child: Text("Log in First"))
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FutureBuilder<Map<String, dynamic>>(
              //   future: _profileFuture,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(child: CircularProgressIndicator());
              //     } else if (snapshot.hasError) {
              //       return Center(child: Text("Error: ${snapshot.error}"));
              //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //       return const Center(child: Text("No profile data found."));
              //     } else {
              //       final profile = snapshot.data!;
              //       return Padding(
              //         padding: const EdgeInsets.all(16.0),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               "Name: ${profile['first_name'] ?? ''}",
              //               style: const TextStyle(fontSize: 18),
              //             ),
              //             const SizedBox(height: 8),
              //             Text(
              //               "Email: ${profile['email'] ?? ''}",
              //               style: const TextStyle(fontSize: 18),
              //             ),
              //           ],
              //         ),
              //       );
              //     }
              //   },
              // ),
              Text(
                "First Name: ${_userData!['first_name'] ?? "Guest "}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Last Name: ${_userData!['last_name'] ?? "Guest "}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Email: ${_userData!['email'] ?? "Guest "}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Phone: ${_userData!['phone'] ?? "012xxxxxxxx "}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Address: ${_userData!['address'] ?? "Unknown"}",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                "Created At: ${_userData!['created_at'] ?? "Unknown"}",
                style: TextStyle(fontSize: 18),
              ),

              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrderScreen()),
                  );
                },
                child: Text("Show Orders"),
              ),
                 SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                    logout();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text("Log Out "),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
