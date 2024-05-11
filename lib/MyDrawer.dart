import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:to_do_app/Authentication/AuthPage.dart';

import 'HomePage.dart';


class myDrawer extends StatefulWidget {
  const myDrawer({super.key});

  @override
  State<myDrawer> createState() => _myDrawerState();
}


class _myDrawerState extends State<myDrawer> {

  TextEditingController nameController = TextEditingController();

  late File ImageFile;
  Uint8List? _image;
  String imageUrlController = '';

  @override
  void initState() {
    super.initState();
    fetchUserProfileData();
  }

  User? user = FirebaseAuth.instance.currentUser;


  Future<void> _pickImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if(pickedFile != null) {
        ImageFile = File(pickedFile.path);
        _image = File(pickedFile.path).readAsBytesSync();
      }
    });
    String? uid = user?.uid;
    String? email = user?.email;
    String? originalFileName = ImageFile.path.split('/').last;
    Reference storageReference = FirebaseStorage.instance.ref().child('$email/profile_pictures/$originalFileName');
    await storageReference.putFile(ImageFile);
    String imageUrlController = await storageReference.getDownloadURL();
    try{
      await FirebaseFirestore.instance.collection("USERS").doc(email).collection('Personal Details').doc(uid).update({
        'Profile Picture': imageUrlController,
      });
    } catch (e) {
      //print('Error: $e');
      Fluttertoast.showToast(msg: 'Error while update profile picture');
    }
  }

  Future SignOut() async {
    try{
      await FirebaseAuth.instance.signOut();
    }
    on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Fluttertoast.showToast(msg: 'Try again..');
    }
  }

  void showMessageDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Dear Learner!"),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await SignOut().then((value) =>
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthPage() ), (route) => false)
                  ); // Close the dialog
                },
                child: const Text('Yes'),
              ),
            ],
          );
        }
    );
  }


  Future<void> fetchUserProfileData() async {
    try{
      String? email = user?.email;
      String? uid = user?.uid;

      DocumentSnapshot document = await FirebaseFirestore.instance.collection("USERS").doc(email).collection('Personal Details').doc(uid).get();
      if(document.exists) {
        Map<String, dynamic> userProfileData = document.data() as Map<String, dynamic>;

        setState(() {
          nameController.text = userProfileData['Name'];
          imageUrlController = userProfileData['Profile Picture'];
        });
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Error during fetch data: $e");
      }
      Fluttertoast.showToast(msg: 'Error during fetch data..');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(context),
            buildMenuItems(context),
          ],
        ),
      ),
    );
  }


  Widget buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.teal,
              Colors.blue.shade400,
              Colors.deepPurple.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              _image != null
                ? CircleAvatar(
                  radius: 52,
                  backgroundImage: MemoryImage(_image!),
                )
                : CircularProfileAvatar(
                    imageUrlController,
                    radius: 52.0,
                    initialsText: Text('  Upload ', style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.transparent,
                ),
              Positioned(
                bottom: -5.0,
                left: 70.0,
                child: IconButton(
                    onPressed: _pickImage,
                    icon: Icon(Icons.add_a_photo_rounded)
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(nameController.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          Text(user?.email ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Container(
      color: Colors.deepPurple.shade400,
      child: Container(
          height: MediaQuery.of(context).size.height * 0.70,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(60),
              )
          ),
          child: Wrap(
            runSpacing: 24,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconColor: Colors.deepPurple,
                textColor: Colors.deepPurple,
                onTap: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
              ListTile(
                  leading: const Icon(Icons.output_rounded),
                  title: const Text('Log Out',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  iconColor: Colors.deepPurple,
                  textColor: Colors.deepPurple,
                  onTap: () {
                    Navigator.pop(context);
                    showMessageDialog(context, 'Do you really want to log out?');
                  }
              ),
            ],
          )
      ),
    );
  }
}