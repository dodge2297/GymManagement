import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedCountryCode = "+1";
  String? _selectedBloodGroup;
  File? _imageFile;

  final List<String> _bloodGroups = [
    "A+",
    "A-",
    "B+",
    "B-",
    "AB+",
    "AB-",
    "O+",
    "O-"
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profileImage');

    setState(() {
      _nameController.text = prefs.getString('name') ?? "Lebron James";
      _emailController.text = prefs.getString('email') ?? "impact@gmail.com";
      _ageController.text = prefs.getString('age') ?? "";
      _phoneController.text = prefs.getString('phone') ?? "";
      _addressController.text = prefs.getString('address') ?? "";
      _selectedCountryCode = prefs.getString('countryCode') ?? "+1";
      _selectedBloodGroup = prefs.getString('bloodGroup');
      _imageFile = imagePath != null ? File(imagePath) : null;
    });
  }

  Future<void> _saveProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('age', _ageController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('address', _addressController.text);
    await prefs.setString('countryCode', _selectedCountryCode);
    if (_selectedBloodGroup != null) {
      await prefs.setString('bloodGroup', _selectedBloodGroup!);
    }
    if (_imageFile != null) {
      await prefs.setString('profileImage', _imageFile!.path);
    }
    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = pickedFile.name;
      final File savedImage = File('${appDir.path}/$fileName');

      await File(pickedFile.path).copy(savedImage.path);

      setState(() {
        _imageFile = savedImage;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImage', savedImage.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!) as ImageProvider
                      : AssetImage("assets/default_avatar.png"),
                  child: _imageFile == null
                      ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Age"),
              ),
              IntlPhoneField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                initialCountryCode: "US",
                onChanged: (phone) {
                  _selectedCountryCode = phone.countryCode;
                },
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Blood Group"),
                value: _selectedBloodGroup,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue!;
                  });
                },
                items: _bloodGroups.map((String bloodGroup) {
                  return DropdownMenuItem<String>(
                    value: bloodGroup,
                    child: Text(bloodGroup),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: "Address"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
