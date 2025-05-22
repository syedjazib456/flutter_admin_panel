import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io; // Renamed to avoid conflict with `Image.file`
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_io/io.dart';

class AddBabyShopItemPage extends StatefulWidget {
  static const String id = "add_baby_shop_item";
  @override
  _AddBabyShopItemPageState createState() => _AddBabyShopItemPageState();
}

class _AddBabyShopItemPageState extends State<AddBabyShopItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedCategory;

  io.File? _imageFile = null;
  final imagepicker = ImagePicker();
  List<XFile> images = [];
  List<String> imageUrls = [];
  // Function to pick an image
  Future<void> pickImage() async {
    final List<XFile>? pickimage = await imagepicker.pickMultiImage();
    if (pickimage != null) {
      setState(() {
        images.addAll(pickimage);
      });
    } else {
      print("No images Selected");
    }
  }

  Future postImages(XFile? imagefile) async {
    String urls;
    Reference ref =
        FirebaseStorage.instance.ref().child("images").child(imagefile!.name);
    if (kIsWeb) {
      await ref.putData(await imagefile.readAsBytes(),
          SettableMetadata(contentType: "images/jpeg"));
      urls = await ref.getDownloadURL();
      return urls;
    }
  }

  uploadimages() async {
    for (var image in images) {
      await postImages(image).then((downloadUrl) => imageUrls.add(downloadUrl));
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Baby shop item added successfully'),
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

  Future<void> _addBabyShopItem() async {
    if (_formKey.currentState!.validate()) {
      String itemId = randomAlphaNumeric(10);
      String itemName = _nameController.text;
      String itemPrice = _priceController.text;
      String? imageUrl;

      await uploadimages();

      await FirebaseFirestore.instance
          .collection('baby_shop_items')
          .doc(itemId)
          .set({
        'item_id': itemId,
        'item_name': itemName,
        'item_price': itemPrice,
        'category': _selectedCategory,
        'image_url': imageUrls,
      });

      _showSuccessDialog(context);
      _nameController.clear();
      _priceController.clear();
      setState(() {
        _selectedCategory = null;
        _imageFile = null;
        imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Baby Shop Item'),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add New Baby Shop Item',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 400.0,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an item name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: 400.0,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Item Price',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an item price';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('categories')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return CircularProgressIndicator();
                      }
                      var categories = snapshot.data!.docs
                          .map((doc) => doc['cat_name'])
                          .toList();
                      return Container(
                        width: 400.0,
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  if (_imageFile != null)
                    kIsWeb
                        ? Image.network(_imageFile!.path,
                            height: 200) // Display local image path on web
                        : Image.file(_imageFile!,
                            height:
                                200) // Display local image file on mobile/desktop
                  else if (imageUrls != null)
                    Container(
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(bottom: 10.0),
                      height: 100.0,
                      width: 400.0,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 10),
                          itemCount: images.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Stack(children: [
                              Image.network(
                                File(images[index].path).path,
                                width: 150.0,
                                height: 150.0,
                                fit: BoxFit.cover,
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      images.removeAt(index);
                                    });
                                  },
                                  icon: Icon(Icons.cancel_outlined))
                            ]);
                          }),
                    ) // Display uploaded image URL
                  else
                    Text('No image selected'),
                  ElevatedButton(
                    onPressed: () async {
                      await pickImage();
                    },
                    child: Text('Pick Image'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addBabyShopItem,
                    child: Text(
                      'Add Item',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(50.0, 50.0),
                        backgroundColor:
                            const Color.fromARGB(255, 13, 93, 158)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
