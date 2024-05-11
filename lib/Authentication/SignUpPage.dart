import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';


class SignUpPage extends StatefulWidget {

  final Function() onClickedSignIn;

  const SignUpPage({Key? key, required this.onClickedSignIn}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  bool _isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  Future signUp() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
      Fluttertoast.showToast(msg: 'Accounted created successfully');
    }
    on FirebaseException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future saveProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;
    String? uid = user?.uid;

    try{
      await FirebaseFirestore.instance.collection("USERS").doc(email).collection("Personal Details").doc(uid).set({
        'Name': nameController.text,
        'Email Id': emailController.text,
        'Profile Picture': '',
      });
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Error while saving personal details on firebase: $e");
      }
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.28,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("Create your account :-",
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.90,
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.teal,
                      Colors.blue.shade400,
                      Colors.deepPurple.shade400,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        TextFormField(
                          controller: nameController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'Required!'),
                            MinLengthValidator(4, errorText: 'Enter a valid name'),
                            MaxLengthValidator(15, errorText: 'Only 15 characters are allowed!')
                          ]),
                          decoration: InputDecoration(
                            labelText: 'Your Name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: emailController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: MultiValidator([
                            EmailValidator(errorText: 'Enter a valid email'),
                            RequiredValidator(errorText: 'Required!'),
                          ]),
                          decoration: InputDecoration(
                            labelText: 'Enter email',
                            prefixIcon: const Icon(Icons.mail_lock_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passController,
                          obscureText: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: MultiValidator([
                            RequiredValidator(errorText: 'Required!'),
                            MinLengthValidator(6, errorText: 'At least 6 characters mandatory!'),
                            MaxLengthValidator(16, errorText: 'Not exceed 16 characters!'),
                          ]),
                          decoration: InputDecoration(
                            labelText: 'Set password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: confirmPassController,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if(value != passController.text){
                              return 'mismatch password';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            prefixIcon: const Icon(Icons.lock_open_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.54,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(54),
                                elevation: 8,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState?.validate() ?? false) {
                                  // Form is valid, proceed with sign up
                                  try {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    await signUp();
                                    await saveProfileData();
                                  } catch (error) {
                                    // Handle errors during sign-up
                                    if (kDebugMode) {
                                      print("Error during sign-up: $error");
                                    }
                                    Fluttertoast.showToast(msg: 'Something went wrong!');
                                    // You might want to show an error message to the user here
                                  } finally {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                              child: _isLoading
                                  ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SpinKitCircle(
                                    color: Colors.deepPurple,
                                    size: 40.0,
                                  ),
                                  SizedBox(width: 10),
                                  Text("Please Wait..",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              )
                                  : const Text(
                                "Sign Up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                          ),
                        ),
                        const SizedBox(height: 30),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
                            text: "Already have an account?",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = widget.onClickedSignIn,
                                text: " Log In",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
