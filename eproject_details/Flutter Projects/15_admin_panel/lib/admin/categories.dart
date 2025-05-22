import 'package:admin_panel/service/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class Categories extends StatefulWidget {
  const Categories({super.key});
  static const String id = "categories";
  @override
  State<Categories> createState() => _Categories();
}

class _Categories extends State<Categories> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  Stream? categoryStream;

  getontheload() async {
    categoryStream = await DatabaseMethods().getcategories();
    setState(() {});
  }

  @override
  void initState() {
    getontheload();
    super.initState();
  }

  Widget viewcategories() {
    return StreamBuilder(
        stream: categoryStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data.docs.isEmpty) {
            return Center(child: Text("No Categories available"));
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(
                  label: Center(child: Text('Category Name')),
                ),
                DataColumn(
                  label: Center(child: Text('Actions')),
                ),
              ],
              rows: snapshot.data.docs.map<DataRow>((DocumentSnapshot ds) {
                return DataRow(cells: [
                  DataCell(Text(ds["cat_name"] ?? 'N/A')),
                  DataCell(
                    Row(children: [
                      GestureDetector(
                        onTap: () async {
                          await _editCategory(ds.id, ds["cat_name"]);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await DatabaseMethods().deletecategories(ds.id);
                        },
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ]),
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
              "All Categories",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 30.0),
          Expanded(child: viewcategories()),
        ],
      ),
    );
  }

  Future<void> _editCategory(String catId, String currentName) async {
    _categoryController.text = currentName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'Category Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await FirebaseFirestore.instance
                      .collection('categories')
                      .doc(catId)
                      .update({
                    'cat_name': _categoryController.text,
                  });
                  Navigator.of(context).pop();
                  _showSuccessDialog(context, 'Category edited successfully');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
