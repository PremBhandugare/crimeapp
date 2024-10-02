import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<dynamic> emergencyContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchEmergencyContacts();
  }

  Future<void> _fetchEmergencyContacts() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch user document from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          emergencyContacts = data['emergencyNumber'] ?? []; // Fetch emergency contacts list
        });
      }
    }
  }

  Future<void> _removeContact(String contact) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Remove the contact from Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'emergencyNumber': FieldValue.arrayRemove([contact]), // Remove the contact from Firestore list
      });

      // Update the local list
      setState(() {
        emergencyContacts.remove(contact);
      });
    }
  }

  Future<void> _addContact(String contact) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Add the contact to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'emergencyNumber': FieldValue.arrayUnion([contact]), // Add the contact to Firestore list
      });

      // Update the local list
      setState(() {
        emergencyContacts.add(contact);
      });
    }
  }

  void _showAddContactDialog() {
    TextEditingController contactController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Emergency Contact'),
          content: TextField(
            controller: contactController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(hintText: 'Enter contact number'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (contactController.text.isNotEmpty) {
                  _addContact(contactController.text);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Contacts'),
      ),
      body: emergencyContacts.isEmpty
          ? Center(child: Text('No emergency contacts available.'))
          : ListView.builder(
              itemCount: emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = emergencyContacts[index];

                return Dismissible(
                  key: Key(contact),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    // Remove the contact when dismissed
                    _removeContact(contact);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$contact removed')),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color.fromARGB(255, 255, 68, 68),
                            child: Icon(Icons.phone, color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emergency Contact',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  contact,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _removeContact(contact);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
floatingActionButton: ElevatedButton.icon(
  icon: Icon(Icons.add),
  label: Text('Add Contact'),
  onPressed: _showAddContactDialog, // Call the add contact dialog
  style: ElevatedButton.styleFrom(
    foregroundColor: Colors.white, backgroundColor: const Color.fromARGB(255, 243, 33, 33), // Text and icon color
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
),

    );
  }
}
