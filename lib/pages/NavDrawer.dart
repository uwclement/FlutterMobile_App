import 'package:flutter/material.dart' hide Theme;
import 'package:provider/provider.dart';
import 'package:mobile_app_flutter/pages/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../Data/database_helper.dart';

class NavDrawer extends StatefulWidget {
  final Function(int) onItemSelected;

  const NavDrawer({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  File? _image;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    String? imagePath = await _databaseHelper.getProfileImage();
    if (imagePath != null) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = path.basename(pickedFile.path);
      final File localImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      // Update the image in the database
      await _databaseHelper.saveProfileImage(localImage.path);

      setState(() {
        _image = localImage;
      });
      if (mounted) {
        Navigator.pop(context); // Close the modal after picking an image
      }
    }
  }

  void _showImageSourceOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Select from Gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Picture'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 180,
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 36, 42, 57),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () => _showImageSourceOptions(context),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.person, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('Sign In'),
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(0);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Sign Up'),
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(1);
            },
          ),
          ListTile(
            leading: const Icon(Icons.calculate),
            title: const Text('Calculator'),
            onTap: () {
              Navigator.pop(context);
              widget.onItemSelected(2);
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('Toggle Theme'),
            trailing: Consumer<ThemeProvider>(
              builder: (BuildContext ctx, ThemeProvider themeProvider, Widget? child) {
                return Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}