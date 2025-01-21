import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seawind/Database.dart';
import 'package:seawind/modelclass.dart';
import 'AddContactScreen.dart';
import 'ViewContact.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DatabaseConnection _databaseConnection = DatabaseConnection();

  void initState(){
    super.initState();
    getAllContacts();
  }
  List<ContactModel> _contactList = [];
  getAllContacts() async {
    _contactList.clear();
    List contacts = await _databaseConnection.readData('Contacts');
    contacts.forEach((cat){
      setState(() {
        ContactModel c = ContactModel();
        c.id = cat['id'];
        c.firstname = cat['firstname'];
        c.lastname = cat['lastname'];
        c.phone = cat['phone'];
        c.email = cat['email'];
        c.company = cat['company'];
        c.state = cat['state'];
        c.city = cat['city'];
        c.street = cat['street'];
        c.zip = cat['zip'];
        c.dppath = cat['dppath'];

        _contactList.add(c);
        _contactList.sort((a, b) => a.firstname!.compareTo(b.firstname!));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: 'Search by name or blood type',
              suffixIcon: Icon(Icons.search),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: 15),
                  Text('All Contacts',style: TextStyle(fontWeight: FontWeight.w600),)
                ],
              ),
              Row(
                children: [
                  Icon(Icons.more_vert),
                  SizedBox(width: 10)
                ],
              )
            ],
          ),
          Divider(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _contactList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0), // Increase tile padding
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: _contactList[index].dppath != null && _contactList[index].dppath!.isNotEmpty
                        ? FileImage(File(_contactList[index].dppath!)) // Load image from local file
                        : null, // Set to null to show the icon instead
                    child: _contactList[index].dppath == null || _contactList[index].dppath!.isEmpty
                        ? Icon(Icons.person) // Show person icon if no image
                        : null, // No child if image is present
                  ),
                  title: Text(
                    _contactList[index].firstname.toString(),
                    style: TextStyle(fontSize: 21),
                  ),
                  subtitle: Text(_contactList[index].company.toString()),
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewContact(contact: _contactList[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AddContact()));
        },
        child: Icon(Icons.add),
        tooltip: 'Add Contact',
      ),
    );
  }
}
