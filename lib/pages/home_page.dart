// ignore_for_file: use_super_parameters

import 'package:employee_details/pages/add_details.dart';
import 'package:employee_details/pages/emp_editor.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
 // AddEmployeePage
 // EditEmployeePage

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            "EMPLOYEES DETAILS",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeePage()), // Navigate to AddEmployeePage
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('EmpDetails').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No employees found'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) => EmployeeListItem(documentSnapshot: docs[index]), // EmployeeListItem
          );
        },
      ),
    );
  }
}

class EmployeeListItem extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> documentSnapshot; // DocumentSnapshot

  const EmployeeListItem({
    Key? key,
    required this.documentSnapshot,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ds = documentSnapshot;

    final DateTime dateOfJoining = DateFormat('dd/MM/yyyy').parse(ds['DateOfJoining']); // Date parsing
    final int differenceInYears = DateTime.now().year - dateOfJoining.year;
    final bool isHighlighted = differenceInYears >= 5 && ds['CurrentlyWorking']; // Highlighting condition

    return Container(
      margin: const EdgeInsets.all(10),
      child: Material(
        elevation: 20,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: isHighlighted ? Colors.green.withOpacity(0.3) : Colors.white, // Highlighted color
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Name: ${ds['Name']}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditEmployeePage(documentId: ds.id), // Navigate to EditEmployeePage
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, ds.id), // Confirm deletion
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Date of Joining: ${ds['DateOfJoining']}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Currently Working: ${ds['CurrentlyWorking'] ? 'Yes' : 'No'}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Confirm deletion
  void _confirmDelete(BuildContext context, String documentId) { 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this employee details ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel deletion
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteEmployee(context, documentId); // Delete employee
                Navigator.of(context).pop();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
  // Delete employee
  void _deleteEmployee(BuildContext context, String documentId) { 
    FirebaseFirestore.instance
        .collection("EmpDetails")
        .doc(documentId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete employee: $error')),
      );
    });
  }
}
