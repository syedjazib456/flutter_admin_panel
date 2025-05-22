import 'package:admin_panel/service/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class BookingAdmin extends StatefulWidget {
  const BookingAdmin({super.key});
  static const String id = "booking_admin";

  @override
  State<BookingAdmin> createState() => _BookingAdminState();
}

class _BookingAdminState extends State<BookingAdmin> {
  Stream? BookingStream;

  getontheload() async {
    BookingStream = await DatabaseMethods().getBookings();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget allbookings() {
    return StreamBuilder(
        stream: BookingStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.docs.isEmpty) {
            return Center(child: Text("No bookings available"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Service')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Time')),
                DataColumn(label: Text('Action')),
              ],
              rows: snapshot.data.docs.map<DataRow>((DocumentSnapshot ds) {
                return DataRow(cells: [
                  DataCell(Text(ds["Service"] ?? 'N/A')),
                  DataCell(Text(ds["Date"] ?? 'N/A')),
                  DataCell(Text(ds["Email"] ?? 'N/A')),
                  DataCell(Text(ds["Time"] ?? 'N/A')),
                  DataCell(
                    GestureDetector(
                      onTap: () async {
                        await DatabaseMethods().deletebooking(ds.id);
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          "Done",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      child: Column(
        children: [
          Center(
            child: Text(
              "All Bookings",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Expanded(child: allbookings()),
        ],
      ),
    );
  }
}
