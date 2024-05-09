// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditEmployeePage extends StatefulWidget {
  final String documentId; // Employee document ID

  const EditEmployeePage({Key? key, required this.documentId}) : super(key: key);

  @override
  _EditEmployeePageState createState() => _EditEmployeePageState();
}

class _EditEmployeePageState extends State<EditEmployeePage> {
  final TextEditingController _nameController = TextEditingController(); // Name controller
  final TextEditingController _dateOfJoiningController = TextEditingController(); // Date of joining controller
  bool _currentlyWorking = false; // Currently working status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Employee"), // App bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('EmpDetails')
              .doc(widget.documentId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Loading indicator
            }
            if (!snapshot.hasData || snapshot.data!.data() == null) {
              return const Center(child: Text('Employee not found')); // Employee not found message
            }
            var data = snapshot.data!.data()!;
            _nameController.text = data['Name']; // Set name controller value
            _dateOfJoiningController.text = data['DateOfJoining']; // Set date of joining controller value
            _currentlyWorking = data['CurrentlyWorking']; // Set currently working status

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'), // Name input field
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _dateOfJoiningController,
                  decoration:
                      const InputDecoration(labelText: 'Date of Joining(DD/MM/YYYY)'), // Date of joining input field
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Currently Working: '), // Currently working label
                    Checkbox(
                      value: _currentlyWorking,
                      onChanged: (value) {
                        setState(() {
                          _currentlyWorking = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      _updateEmployee();
                    },
                    child: const Text('Update Employee'), // Update employee button
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _updateEmployee() {
    String name = _nameController.text; // Get name
    String dateOfJoining = _dateOfJoiningController.text; // Get date of joining

    if (name.isNotEmpty && dateOfJoining.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('EmpDetails')
          .doc(widget.documentId)
          .update({
        'Name': name,
        'DateOfJoining': dateOfJoining,
        'CurrentlyWorking': _currentlyWorking,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee updated successfully')), // Employee updated successfully message
        );
        Navigator.pop(context); // Navigate back to the home page
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update employee: $error')), // Failed to update employee message
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')), // Please enter all fields message
      );
    }
  }
}
