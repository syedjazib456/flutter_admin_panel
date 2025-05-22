import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future addEmployeeDetails(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .set(userInfoMap);
  }

  Future addUserbooking(Map<String, dynamic> bookingInfoMap) async {
    return await FirebaseFirestore.instance
        .collection("booking")
        .add(bookingInfoMap);
  }

  Future<Stream<QuerySnapshot>> getBookings() async {
    return await FirebaseFirestore.instance.collection("booking").snapshots();
  }

  Future<Stream<QuerySnapshot>> getcategories() async {
    return await FirebaseFirestore.instance
        .collection("categories")
        .snapshots();
  }

  Future deletebooking(String id) async {
    return await FirebaseFirestore.instance
        .collection("booking")
        .doc(id)
        .delete();
  }

  Future deletecategories(String id) async {
    return await FirebaseFirestore.instance
        .collection("categories")
        .doc(id)
        .delete();
  }

  Future<Stream<QuerySnapshot>> fetchitems() async {
    return await FirebaseFirestore.instance
        .collection("baby_show_items")
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> fetchcategory() async {
    return await FirebaseFirestore.instance
        .collection("categories")
        .snapshots();
  }
}
