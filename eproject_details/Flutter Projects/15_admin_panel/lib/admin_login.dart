import 'package:admin_panel/service/shared_pref_admin.dart';
import 'package:admin_panel/web_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';



class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  TextEditingController namecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  SharedPreferenceHelper sharedPrefHelper =
      SharedPreferenceHelper(); // Initialize the helper

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        child: Stack(children: [
          Container(
            padding: EdgeInsets.only(left: 50.0, top: 20.0),
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xFFB91635),
              Color(0xff621d3c),
              Color(0xFF311937)
            ])),
            child: Text(
              "Admin\nPanel",
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: 40.0, left: 30.0, right: 30.0, bottom: 30.0),
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40.0,
                  ),
                  Text(
                    "Username",
                    style: TextStyle(
                        color: Color(0xFFB91635),
                        fontSize: 23.0,
                        fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Your Name";
                      }
                      return null;
                    },
                    controller: namecontroller,
                    decoration: InputDecoration(
                        hintText: "Type your name here....",
                        prefixIcon: Icon(Icons.mail_outline)),
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Text(
                    "Password",
                    style: TextStyle(
                        color: Color(0xFFB91635),
                        fontSize: 23.0,
                        fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please Enter Your Password";
                      }
                      return null;
                    },
                    controller: passwordcontroller,
                    decoration: InputDecoration(
                        hintText: "Password", prefixIcon: Icon(Icons.password)),
                    obscureText: true,
                  ),
                  SizedBox(
                    height: 28.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      loginAdmin();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Color(0xFFB91635),
                            Color(0xff621d3c),
                            Color(0xFF311937)
                          ]),
                          borderRadius: BorderRadius.circular(30.0)),
                      child: Center(
                        child: Text(
                          "Log In",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 23.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ]),
      ),
    ));
  }

  loginAdmin() {
    FirebaseFirestore.instance.collection("admin").get().then((snapshot) {
      bool credentialsCorrect = false;
      snapshot.docs.forEach((result) {
        if (result.data()['name'] == namecontroller.text.trim() &&
            result.data()['password'] == passwordcontroller.text.trim()) {
          credentialsCorrect = true;
          sharedPrefHelper.saveAdminData(
            result.data()['name'],
          ); // Save admin data in shared preferences
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => WebMain()));
        }
      });

      if (!credentialsCorrect) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color.fromARGB(255, 230, 73, 52),
            content: Text(
              "Your Given Credentials is not Correct",
              style: TextStyle(fontSize: 20.0),
            )));
      }
    });
  }
}
