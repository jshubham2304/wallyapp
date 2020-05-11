import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Add_Wallpaper_Screen extends StatefulWidget {
  @override
  _Add_Wallpaper_ScreenState createState() => _Add_Wallpaper_ScreenState();
}

class _Add_Wallpaper_ScreenState extends State<Add_Wallpaper_Screen> {
  File _file;
  bool isuploading = false;
  bool isSuccess = false;
  var labelToString = [];
  final ImageLabeler imageLabeler = FirebaseVision.instance.imageLabeler();
  List<ImageLabel> labels;
  final Firestore _db = Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  @override
  void dispose() {
    imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade400,
        title: Text("Add Wallpaper"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              InkWell(
                child: _file != null
                    ? Image.file(_file)
                    : Image(
                        image: AssetImage("assets/placeholder.jpg"),
                      ),
                onTap: loadImage,
              ),
              SizedBox(
                height: 5,
              ),
              Text("Click on image to Upload the Wallpaper"),
              SizedBox(
                height: 20,
              ),
              labels != null
                  ? Wrap(
                      children: labels.map((f) {
                      return Chip(
                        padding: EdgeInsets.all(8.0),
                        label: Text(f.text),
                      );
                    }).toList())
                  : Container(),
              SizedBox(
                height: 50,
              ),
              if (isuploading) ...[Text("Uploading wallpaper ...  ")],
              if (isSuccess) ...[Text("Uploaded Successfully ...  ")],
              SizedBox(
                height: 50,
              ),
              RaisedButton(
                onPressed: uploadImage,
                child: Text("Upload Wallpaper"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void loadImage() async {
     _file = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 30);
    final FirebaseVisionImage visionImage =
        await FirebaseVisionImage.fromFile(_file);
    List<ImageLabel> labelsNew = await imageLabeler.processImage(visionImage);

    for (var lab in labelsNew) {
      labelToString.add(lab.text);
    }

    setState(() {
      _file = _file;
      labels = labelsNew;
    });
  }

  void uploadImage() async {
    if (_file != null)
     {
      String filename = path.basename(_file.path);
      FirebaseUser user = await auth.currentUser();
      String uuid = user.uid;
      StorageUploadTask uploadtask = _storage
          .ref()
          .child("wallpapers")
          .child(uuid)
          .child(filename)
          .putFile(_file);
      uploadtask.events.listen((e) {
        if (e.type == StorageTaskEventType.progress) {
          setState(() {
            isuploading = true;
          });
        }
        if (e.type == StorageTaskEventType.success) {
          setState(() {
            isSuccess = true;
            isuploading = false;
          });
          e.snapshot.ref.getDownloadURL().then((value) {
            _db.collection("wallpapers").add({
              "url": value,
              "date": DateTime.now(),
              "uploaded_by": uuid,
              "tag": labelToString,
            });
          }).then((value) {
            Navigator.of(context).pop();
          });

        }
        }
      );
        } else {
          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: Text("Error"),
                  content: Text("Select the image to upload......."),
                  actions: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Okay"),
                    )
                  ],
                );
              });
        }
    
  }
}
