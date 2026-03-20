import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final XFile? currentImage;

  const EditProfilePage({
    super.key,
    required this.currentName,
    this.currentImage,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  XFile? _image;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    _image = widget.currentImage;
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  /// ✅ ตัวนี้สำคัญมาก
  Widget _buildProfileImage() {
    if (_image == null) {
      return const Icon(Icons.person, size: 50);
    }

    // 🌐 WEB
    if (kIsWeb) {
      return FutureBuilder<Uint8List>(
        future: _image!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ClipOval(
              child: Image.memory(
                snapshot.data!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            );
          }
          return const CircularProgressIndicator();
        },
      );
    }

    // 📱 MOBILE
    return ClipOval(
      child: Image.file(
        File(_image!.path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? Colors.transparent : Colors.white,
        elevation: 0,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
      ),
      body: Container(
        decoration:
            isDark ? AppTheme.darkGradient : null,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              /// ✅ แก้ตรงนี้
              CircleAvatar(
                radius: 50,
                backgroundColor:
                    isDark ? Colors.white10 : Colors.white,
                child: _buildProfileImage(),
              ),

              TextButton(
                onPressed: _pickImage,
                child: const Text("Change Profile Picture"),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: nameController,
                style: TextStyle(
                  color:
                      isDark ? Colors.white : AppTheme.textDark,
                ),
                decoration: InputDecoration(
                  labelText: "Full Name",
                  filled: true,
                  fillColor: isDark
                      ? AppTheme.inputDark
                      : AppTheme.inputLight,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      "name": nameController.text,
                      "image": _image,
                    });
                  },
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}