import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'HomeScreen.dart';
import 'database.dart';
import 'modelclass.dart';
import 'package:path/path.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _pickImage() async {
    PermissionStatus permissionStatus = await Permission.photos.request();

    if (permissionStatus.isGranted) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String newPath = join(directory.path, pickedFile.name);

        await File(pickedFile.path).copy(newPath);

        setState(() {
          _imageFile = pickedFile;
          _contactModel.dppath = newPath;
        });
      }
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar( content: Text('Permission To Access Photos Was Denied.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));

          },
          icon: Icon(Icons.arrow_back),
        ),
        title:Text('Add New Contact'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _contactModel.firstname = _firstNameController.text;
              _contactModel.lastname = _lastNameController.text;
              _contactModel.phone = _phoneController.text;
              _contactModel.email = _emailController.text;
              _contactModel.company = _companyController.text;
              _contactModel.state = _stateController.text;
              _contactModel.city = _cityController.text;
              _contactModel.street = _streetController.text;
              _contactModel.zip = _zipController.text;

              _databaseConnection.insertData('Contacts', _contactModel.ContactMap());
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));

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
                onPressed: _pickImage,
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

