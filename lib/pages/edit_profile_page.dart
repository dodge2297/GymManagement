import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login_register');
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _nameController.text = "Lebron James";
          _emailController.text = user.email ?? "impact@gmail.com";
        });
        return;
      }

      final data = userDoc.data()!;
      File? imageFile;
      if (data['profileImage'] != null) {
        File tempFile = File(data['profileImage']);
        if (await tempFile.exists()) {
          imageFile = tempFile;
        }
      }

      setState(() {
        _nameController.text = data['name'] ?? "Lebron James";
        _emailController.text =
            data['email'] ?? user.email ?? "impact@gmail.com";
        _ageController.text = data['age']?.toString() ?? "";
        _phoneController.text = data['phone']?.toString() ?? "";
        _addressController.text = data['address']?.toString() ?? "";
        _selectedCountryCode = data['countryCode']?.toString() ?? "+1";
        _selectedBloodGroup = data['bloodGroup']?.toString();
        _imageFile = imageFile;
      });

      if (imageFile != null) {
        precacheImage(FileImage(imageFile), context);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to load profile: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login_register');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text,
        'email': _emailController.text,
        'age': _ageController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'countryCode': _selectedCountryCode,
        'bloodGroup': _selectedBloodGroup,
        'profileImage': _imageFile?.path,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast(
            title: const Text('Success'),
            description: const Text('Profile updated successfully'),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ShadToaster.of(context).show(
          ShadToast.destructive(
            title: const Text('Error'),
            description: Text('Failed to update profile: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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

      precacheImage(FileImage(savedImage), context);
    }
  }

  Future<void> _deleteProfilePhoto() async {
    if (_imageFile != null && await _imageFile!.exists()) {
      await _imageFile!.delete();
    }

    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!) as ImageProvider
                          : null,
                      backgroundColor: Colors.grey[300],
                      child: _imageFile == null
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  if (_imageFile != null) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _deleteProfilePhoto,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              IntlPhoneField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number"),
                initialCountryCode: "US",
                onChanged: (phone) {
                  _selectedCountryCode = phone.countryCode;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Blood Group"),
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
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
