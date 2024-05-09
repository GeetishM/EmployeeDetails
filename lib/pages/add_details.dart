// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({Key? key}) : super(key: key);

  @override
  _AddEmployeePageState createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final TextEditingController _nameController = TextEditingController(); // Name controller
  final TextEditingController _dateOfJoiningController = TextEditingController(); // Date of joining controller
  bool _currentlyWorking = false; // Currently working status

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Employee"), // App bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'), // Name input field
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _dateOfJoiningController,
                decoration: const InputDecoration(labelText: 'Date of Joining(DD/MM/YYYY)'), // Date of joining input field
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
                    _addEmployee();
                  },
                  child: const Text('Add Employee'), // Add employee button
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addEmployee() {
    String name = _nameController.text; // Get the name
    String dateOfJoining = _dateOfJoiningController.text; // Get the date of joining

    try {
      // Try parsing the date
      DateFormat('dd/MM/yyyy').parse(dateOfJoining);
    } catch (e) {
      // Handle invalid date format
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text("Invalid date format. Please enter the date in the format DD/MM/YYYY."), // Invalid date format message
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"), // OK button
              ),
            ],
          );
        },
      );
      return;
    }

    if (name.isNotEmpty && dateOfJoining.isNotEmpty) {
      FirebaseFirestore.instance.collection('EmpDetails').add({
        'Name': name,
        'DateOfJoining': dateOfJoining,
        'CurrentlyWorking': _currentlyWorking,
      }).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully')), // Employee added successfully message
        );
        Navigator.pop(context); // Return to the previous screen
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add employee: $error')), // Failed to add employee message
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')), // Please enter all fields message
      );
    }
  }
}

