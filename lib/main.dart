import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io' show Platform;

import 'Authentication/AuthPage.dart';
import 'HomePage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

Platform.isAndroid
  ? await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyD9N3wBb2L9y66bwzJTX2fgP_WgCN5vjtI",
        appId: "1:976542376660:android:b338ade4e9293878015141",
        messagingSenderId: "976542376660",
        storageBucket: "gs://to-do-app-edbcc.appspot.com",
        projectId: "to-do-app-edbcc",
      ),
  )
  : await Firebase.initializeApp();

SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
  runApp(const MyApp());
});

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?> (
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: SpinKitCircle(color: Colors.white));
            }
            else if(snapshot.hasError) {
              return Center(child: Text("Something Went Wrong!"));
            }
            else if(snapshot.hasData) {
              return HomePage();
            }
            else {
              return AuthPage();
            }
          },
        )
    );
  }
}
