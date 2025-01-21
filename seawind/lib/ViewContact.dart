import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seawind/Database.dart';
import 'package:seawind/HomeScreen.dart';
import 'package:seawind/modelclass.dart';
import 'package:seawind/updateContact.dart';

class ViewContact extends StatelessWidget {
  final ContactModel contact;

  ViewContact({required this.contact});

  DatabaseConnection _databaseConnection = DatabaseConnection();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit contact'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => updateContact(contact: contact)));
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              if (contact.dppath != null && contact.dppath!.isNotEmpty) {
                final dpFile = File(contact.dppath!);
               await dpFile.delete();
              }
              _databaseConnection.deleteData('Contacts', contact.id);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: contact.dppath != null && contact.dppath!.isNotEmpty
                    ? FileImage(File(contact.dppath!))
                    : null,
                child: contact.dppath == null || contact.dppath!.isEmpty
                    ? Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            SizedBox(height: 10),
            Text('${contact.firstname}  ${contact.lastname}',
            style: TextStyle(fontSize: 30),),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.message),

                Icon(Icons.call),

                Icon(Icons.mail),
              ],
            ),
            Divider(height: 40, thickness: 1),
            ContactDetailRow(label: 'Phone', value: contact.phone ?? ''),
            ContactDetailRow(label: 'Email', value: contact.email ?? ''),
            ContactDetailRow(label: 'Company', value: contact.company ?? ''),
            ContactDetailRow(label: 'City', value: contact.city ?? ''),
            ContactDetailRow(label: 'Address', value: contact.street ?? ''),
            ContactDetailRow(label: 'Zip', value: contact.zip ?? ''),
          ],
        ),
      ),
    );
  }
}

class ContactDetailRow extends StatelessWidget {
  final String label;
  final String value;

  ContactDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
