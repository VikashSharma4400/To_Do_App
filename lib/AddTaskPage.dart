import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/HomePage.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Future saveTaskOnFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;
    DateTime time = DateTime.now();
    String taskId = time.toString();

    try {
      await FirebaseFirestore.instance.collection('USERS').doc(email).collection('Tasks').doc(taskId).set({
        'Title': titleController.text,
        'Description': descriptionController.text,
        'Task Id': taskId,
        'Add Time': DateFormat('dd/MM/yyyy || hh:mm a').format(time),
        'Task Time': '${dateController.text} || ${timeController.text}',
        'isComplete': false,
      }).then((value) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
        Fluttertoast.showToast(msg: 'Task Added...');
      });
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: titleController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'Required!'),
                        MinLengthValidator(4, errorText: 'Too short!'),
                        MaxLengthValidator(22, errorText: 'Title is too long!'),
                      ]),
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: MultiValidator([
                        RequiredValidator(errorText: "Required!"),
                        MaxLengthValidator(42, errorText: 'Description is too long!'),
                        MinLengthValidator(8, errorText: 'Too short!'),
                      ]),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: dateController,
                      readOnly: true,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'Required'),
                      ]),
                      decoration: InputDecoration(
                        labelText: 'Select Date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2025),
                            );
                            if (picked != null) {
                              setState(() {
                                dateController.text = DateFormat('dd/MM/yyyy').format(picked);
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month, color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: TextEditingController(text: timeController.text),
                      readOnly: true,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: MultiValidator([
                        RequiredValidator(errorText: 'Required'),
                      ]),
                      decoration: InputDecoration(
                        labelText: 'Choose Time',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () async {
                            final TimeOfDay? pickedTime = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                              initialEntryMode: TimePickerEntryMode.dial,
                            );
                            if (pickedTime != null) {
                              setState(() {
                                timeController.text = pickedTime.format(context);
                              });
                            }
                          },
                          icon: const Icon(Icons.timer_sharp , color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            try {
                              setState(() {
                                isLoading = true;
                              });
                              await saveTaskOnFirestore();
                            } catch (e) {
                              Fluttertoast.showToast(msg: 'Something went wrong');
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 42,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.teal,
                                  Colors.blue.shade400,
                                  Colors.deepPurple.shade400
                                ],
                              )
                          ),
                          child: isLoading ? const Center(child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [SpinKitCircle(color: Colors.white, size: 35,), Text('Wait',style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))],))
                            : const Center(child: Text('Add Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 42,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.red,
                          ),
                          child: const Center(child: Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)))
                        ),
                      ),
                    ],
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
