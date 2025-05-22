import 'package:admin_panel/admin/addcategories.dart';
import 'package:admin_panel/admin/cartdetail.dart';
import 'package:admin_panel/admin/categories.dart';
import 'package:admin_panel/admin/categoryitems.dart';
import 'package:admin_panel/admin/dashboard.dart';
import 'package:admin_panel/admin/orderdetails.dart';
import 'package:admin_panel/admin/view_categoryitems.dart';
import 'package:admin_panel/admin_login.dart';
import 'package:admin_panel/service/shared_pref_admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';


class WebMain extends StatefulWidget {
  WebMain({Key? key}) : super(key: key);
  static const String id = "web_main";

  @override
  _WebMainState createState() => _WebMainState();
}

class _WebMainState extends State<WebMain> {
  SharedPreferenceHelper sharedPrefHelper = SharedPreferenceHelper();
  String? adminName = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getOnTheLoad();
  }

  getTheDataFromSharedPref() async {
    adminName = await SharedPreferenceHelper().getAdminData();
    setState(() {});
  }

  getOnTheLoad() async {
    await getTheDataFromSharedPref();
    setState(() {});
  }

  void chooseScreen(String? route) {
    switch (route) {
      case Dashboard.id:
        setState(() {
          selectedScreen = Dashboard();
        });
        break;
      case Categories.id:
        setState(() {
          selectedScreen = Categories();
        });
        break;
      case AddCategoryPage.id:
        setState(() {
          selectedScreen = AddCategoryPage();
        });
        break;
      case AddBabyShopItemPage.id:
        setState(() {
          selectedScreen = AddBabyShopItemPage();
        });
        break;
      case ViewCategoryitems.id:
        setState(() {
          selectedScreen = ViewCategoryitems();
        });
        break;
      case OrderDetails.id:
        setState(() {
          selectedScreen = OrderDetails();
        });
        break;
      case CartDetail.id:
        setState(() {
          selectedScreen = CartDetail();
        });
        break;
    }
  }

  Future<void> logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout Confirmation'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                await sharedPrefHelper.clearAdminData();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AdminLogin())); // Replace with your actual login route
              },
            ),
          ],
        );
      },
    );
  }

  Widget selectedScreen = Dashboard();

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Admin Panel",
              style: TextStyle(color: Colors.white),
            ),
            Row(
              children: [
                Text(
                  adminName!.isEmpty ? 'Admin' : adminName!,
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: logout,
                ),
              ],
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      sideBar: SideBar(
        onSelected: (item) => chooseScreen(item.route),
        items: [
          AdminMenuItem(
            title: "DASHBOARD",
            icon: Icons.dashboard,
            route: Dashboard.id,
          ),
          AdminMenuItem(
            title: "View Categories",
            icon: Icons.category,
            route: Categories.id,
          ),
          AdminMenuItem(
            title: "Add Categories",
            icon: Icons.add,
            route: AddCategoryPage.id,
          ),
          AdminMenuItem(
            title: "Category Items",
            icon: Icons.production_quantity_limits,
            route: AddBabyShopItemPage.id,
          ),
          AdminMenuItem(
            title: "View Category Items",
            icon: Icons.view_agenda,
            route: ViewCategoryitems.id,
          ),
          AdminMenuItem(
            title: "View Order Details",
            icon: Icons.outbox_rounded,
            route: OrderDetails.id,
          ),
          AdminMenuItem(
            title: "View Cart Details",
            icon: Icons.card_travel,
            route: CartDetail.id,
          ),
        ],
        selectedRoute: Dashboard.id,
      ),
      body: selectedScreen,
    );
  }
}
