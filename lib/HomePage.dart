import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:to_do_app/AddTaskPage.dart';
import 'package:to_do_app/EditTaskPage.dart';

import 'Api/FirestoreApi.dart';
import 'MyDrawer.dart';
import 'TaskDetailsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  Future<Map<String, Map<String, dynamic>>> fetchDataFromFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;

    final List<String> documentIds = await FirestoreApi.listAllDocuments('USERS', email!, 'Tasks');
    Map<String, Map<String, dynamic>> result = {};

    for(String documentId in documentIds) {
      final Map<String, dynamic> documentData = await FirestoreApi.getDocumentData('USERS', email, 'Tasks', documentId);
      result[documentId] = documentData;
    }
    return result;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const myDrawer(),
      appBar: AppBar(
        title: const Text('Do Your Task'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, Map<String, dynamic>>> (
        future: fetchDataFromFirestore(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              final Map<String, Map<String, dynamic>>? myDocument = snapshot.data;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: myDocument?.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Shimmer.fromColors(
                            baseColor: CupertinoColors.systemGrey,
                            highlightColor: CupertinoColors.systemGrey5,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.94,
                              height: MediaQuery.of(context).size.height * 0.20,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                          ),
                        );
                      }
                    ),
                  ),
                ],
              );

            default:
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong!'));
              }
              else if(snapshot.data == null || snapshot.data!.isEmpty) {
                return const Center(child: Text('No task added yet!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,)));
              }
              else {
                final Map<String, Map<String, dynamic>> myDocument = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: myDocument.length,
                        itemBuilder: (context, index) {
                          final documentId = myDocument.keys.elementAt(index);
                          final documentData = myDocument[documentId];

                          return createTask(context, documentData);
                        },
                      ),
                    ),
                  ],
                );
              }
          }
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTaskPage()));
        },
        tooltip: 'Add Task',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add,color: Colors.deepPurple),
      ),
    );
  }

  Widget createTask(BuildContext context, Map<String, dynamic>? documentData) {
    bool isDone = documentData?['isComplete'];
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;
    Future updateStatus(bool isDon) async {

      try {
        await FirebaseFirestore.instance.collection('USERS').doc(email).collection('Tasks').doc(documentData?['Task Id']).update({
          'isComplete': isDon,
        });
      } on FirebaseException catch (e) {
        Fluttertoast.showToast(msg: 'Something went wrong...');
        print(e);
      }
    }

    Future deleteTask() async {
      try {
        await FirebaseFirestore.instance.collection('USERS').doc(email).collection('Tasks').doc(documentData?['Task Id']).delete()
            .then((value) => Fluttertoast.showToast(msg: 'Task deleted...')
        );
      } on FirebaseException catch (e) {
        Fluttertoast.showToast(msg: 'Unable to delete..');
        print(e);
      }
    }

    return
      Padding(
        padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.94,
            height: MediaQuery.of(context).size.height * 0.20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0 , 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(value: isDone, onChanged: (value) {
                      setState(() {
                        isDone = !isDone;
                      });
                      updateStatus(isDone);
                    }),
                    Column(
                      children: [
                        documentData?['isComplete']
                        ? Text(documentData?['Title'], style: const TextStyle( fontSize: 18, decoration: TextDecoration.lineThrough,))
                        : Text(documentData?['Title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18,)),
                        const SizedBox(height: 6),
                        documentData?['isComplete']
                        ? Text(documentData?['Task Time'], style: const TextStyle( fontSize: 14, decoration: TextDecoration.lineThrough,))
                        : Text(documentData?['Task Time'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14,)),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          deleteTask().then((value) {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()),
                                  (route) => false,
                            );
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red,)
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => EditTaskPage(documentData: documentData)));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal,
                              Colors.blue.shade400,
                              Colors.deepPurple.shade400
                            ],
                          )
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit_note_rounded, color: Colors.white),
                            SizedBox(width: 6,),
                            Text('Edit',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailsPage(documentData: documentData)));
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: 38,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(19),
                            gradient: LinearGradient(
                              colors: [
                                Colors.teal,
                                Colors.blue.shade400,
                                Colors.deepPurple.shade400
                              ],
                            )
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notes_rounded , color: Colors.white),
                            SizedBox(width: 6,),
                            Text('README',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ),
      );
  }
}

