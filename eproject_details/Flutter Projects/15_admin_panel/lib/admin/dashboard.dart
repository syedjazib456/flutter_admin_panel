import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  static const String id = "dashboard";

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int totalOrders = 0;
  int totalClients = 0;
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Fetch total number of orders
      QuerySnapshot ordersSnapshot =
          await FirebaseFirestore.instance.collection('orders').get();
      if (mounted) {
        setState(() {
          totalOrders = ordersSnapshot.size;
        });

        // Calculate total amount
        double amount = 0.0;
        for (var doc in ordersSnapshot.docs) {
          List items = doc['items'] ?? [];
          for (var item in items) {
            var price = item['price'];
            if (price is String) {
              amount += double.tryParse(price) ?? 0.0;
            } else if (price is num) {
              amount += price.toDouble();
            }
          }
        }
        setState(() {
          totalAmount = amount;
        });
      }

      // Fetch total number of clients
      QuerySnapshot clientsSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      if (mounted) {
        setState(() {
          totalClients = clientsSnapshot.size;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardHeight = MediaQuery.of(context).size.height * 0.2;
    final double cardWidth = MediaQuery.of(context).size.width * 0.3;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: cardWidth,
                      height: cardHeight,
                      child: Card(
                        color: const Color.fromARGB(255, 89, 170, 236),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.countertops, color: Colors.white),
                                Text(
                                  "Total Orders",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "$totalOrders",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: cardWidth,
                      height: cardHeight,
                      child: Card(
                        color: const Color.fromARGB(255, 89, 170, 236),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.people, color: Colors.white),
                                Text(
                                  "Total Clients",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "$totalClients",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: cardWidth,
                      height: cardHeight,
                      child: Card(
                        color: const Color.fromARGB(255, 89, 170, 236),
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.attach_money, color: Colors.white),
                                Text(
                                  "Total Amount",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "\$${totalAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16), // Add spacing between rows
              // Add more rows of cards if needed
            ],
          ),
        ),
      ),
    );
  }
}
