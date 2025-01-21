import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seawind/HomeScreen.dart';
import 'dart:io';
import 'Database.dart';
import 'modelclass.dart';

class updateContact extends StatefulWidget {
  final ContactModel contact;

  const updateContact({required this.contact});

  @override
  State<updateContact> createState() => _updateContactState();
}

class _updateContactState extends State<updateContact> {
  XFile? _imageFile;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  ContactModel _contactModel = ContactModel();
  DatabaseConnection _databaseConnection = DatabaseConnection();


  void initState(){
    super.initState();
    _firstNameController.text = widget.contact.firstname ?? '';
    _lastNameController.text = widget.contact.lastname ?? '';
    _phoneController.text = widget.contact.phone ?? '';
    _emailController.text = widget.contact.email ?? '';
    _companyController.text = widget.contact.company ?? '';
    _stateController.text = widget.contact.state ?? '';
    _cityController.text = widget.contact.city ?? '';
    _streetController.text = widget.contact.street ?? '';
    _zipController.text = widget.contact.zip ?? '';

    if (widget.contact.dppath != null) {
      _imageFile = XFile(widget.contact.dppath!);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title:Text('Add New Contact'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _contactModel.id = widget.contact.id;
              _contactModel.firstname = _firstNameController.text;
              _contactModel.lastname = _lastNameController.text;
              _contactModel.phone = _phoneController.text;
              _contactModel.email = _emailController.text;
              _contactModel.company = _companyController.text;
              _contactModel.state = _stateController.text;
              _contactModel.city = _cityController.text;
              _contactModel.street = _streetController.text;
              _contactModel.zip = _zipController.text;
              _contactModel.dppath = widget.contact.dppath;

              _databaseConnection.updateData('Contacts', _contactModel.ContactMap());

              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomeScreen()),
                    (Route<dynamic> route) => false);
              },
            icon: const Icon(Icons.check, size: 35,),
            tooltip: 'Save Contact',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(radius: 70,
              child: _imageFile == null
                  ? IconButton(
                icon: Icon(Icons.add_a_photo, size: 70),
                onPressed: (){},
              )
                  : ClipOval(
                child: Image.file(
                  File(_imageFile!.path), width: 140, height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_firstNameController, 'First Name', Icons.person),
            _buildTextField(_lastNameController, 'Last Name', null),
            _buildTextField(_phoneController, 'Phone', Icons.phone, keyboardType: TextInputType.phone),
            _buildTextField(_emailController, 'Email', Icons.email, keyboardType: TextInputType.emailAddress),
            _buildTextField(_companyController, 'Company', Icons.business),
            _buildTextField(_stateController, 'State', Icons.pin_drop),
            _buildTextField(_cityController, 'City',null),
            _buildTextField(_streetController, 'Street', null),
            _buildTextField(_zipController, 'Zip', null),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData? icon, {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: "    ${label}",
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.black,width: 1.4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


