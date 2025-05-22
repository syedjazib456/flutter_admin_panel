import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io show File; // Renamed to avoid conflict with `Image.file`
import 'package:firebase_storage/firebase_storage.dart';
import 'package:universal_io/io.dart';

class ViewCategoryitems extends StatefulWidget {
  static const String id = "view_baby_shop_item";
  const ViewCategoryitems({super.key});

  @override
  State<ViewCategoryitems> createState() => _ViewCategoryitemsState();
}

class _ViewCategoryitemsState extends State<ViewCategoryitems> {
  Future<void> _deleteItem(String itemId) async {
    await FirebaseFirestore.instance
        .collection('baby_shop_items')
        .doc(itemId)
        .delete();
  }

  Future<void> _editItem(DocumentSnapshot item) async {
    TextEditingController _nameController =
        TextEditingController(text: item['item_name']);
    TextEditingController _priceController =
        TextEditingController(text: item['item_price']);
    String? _selectedCategory = item['category'];
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
        await postImages(image)
            .then((downloadUrl) => imageUrls.add(downloadUrl));
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Item'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Item Name'),
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(labelText: 'Item Price'),
                  ),
                  //neglect
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
                      return DropdownButtonFormField<String>(
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
                        decoration: InputDecoration(labelText: 'Category'),
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  if (_imageFile != null)
                    kIsWeb
                        ? Image.network(_imageFile.path,
                            height: 200) // Display local image path on web
                        : Image.file(_imageFile,
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
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await uploadimages();

                  await FirebaseFirestore.instance
                      .collection('baby_shop_items')
                      .doc(item.id)
                      .update({
                    'item_name': _nameController.text,
                    'item_price': _priceController.text,
                    'category': _selectedCategory,
                    'image_url': imageUrls,
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection('baby_shop_items').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final items = snapshot.data!.docs;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Actions')),
            ],
            rows: items.map((item) {
              List<dynamic> imageUrls = item['image_url'] ?? [];
              print(
                  'Image URLs for item ${item.id}: $imageUrls'); // Debugging statement
              return DataRow(cells: [
                DataCell(
                  Row(
                    children: List.generate(imageUrls.length, (index) {
                      print(
                          'Loading image from URL: ${imageUrls[index]}'); // Additional debug statement
                      return Image.network(
                        imageUrls[index],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          print('Error loading image: $error'); // Log the error
                          return Icon(Icons.error);
                        },
                      );
                    }),
                  ),
                ),
                DataCell(Text(item['item_name'])),
                DataCell(Text(item['item_price'])),
                DataCell(Text(item['category'] ?? '')),
                DataCell(
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.green,
                        ),
                        onPressed: () => _editItem(item),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () async {
                          await _deleteItem(item.id);
                        },
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
