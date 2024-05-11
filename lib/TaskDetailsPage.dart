import 'package:flutter/material.dart';

class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? documentData;
  const TaskDetailsPage({super.key, required this.documentData});

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('README'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Center(child: Text(widget.documentData?['Title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22))),
              const SizedBox(height: 12,),
              Text(widget.documentData?['Description'],),
              const SizedBox(height: 30,),
              Row(
                children: [
                  const Text('Deadline:', style: TextStyle( fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(width: 10,),
                  Text(widget.documentData?['Task Time'],),
                ],
              ),
              const SizedBox(height: 12,),
              Row(
                children: [
                  const Text('Task Add On:', style: TextStyle( fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(width: 10,),
                  Text(widget.documentData?['Add Time'],),
                ],
              ),
              const SizedBox(height: 12,),
              widget.documentData?['isComplete']
              ? const Row(
                children: [
                  Text('Status:', style: TextStyle( fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(width: 10,),
                  Text('Task completed.',)
                ],
              )
              : const Row(
                children: [
                  Text('Status:', style: TextStyle( fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(width: 10,),
                  Text('Not yet completed.')
                ],
              ),
              const SizedBox(height: 12,),
            ],
          ),
        ),
      )
    );
  }
}
