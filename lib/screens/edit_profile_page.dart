import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_background.dart';
import '../data/profile_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:typed_data';
import '../l10n/app_strings.dart';

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
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (pickedFile == null) {
      return;
    }

    if (kIsWeb) {
      setState(() {
        _image = pickedFile;
      });
      return;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 92,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Profile Image',
          toolbarColor: AppTheme.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppTheme.primary,
          lockAspectRatio: true,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.square,
        ),
        IOSUiSettings(
          title: 'Crop Profile Image',
          aspectRatioLockEnabled: true,
          rotateButtonsHidden: false,
          resetButtonHidden: false,
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        _image = XFile(cropped.path);
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
    final s = AppStrings.of(context);
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          s.editProfile,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppTheme.textDark,
        ),
      ),
      body: SoftBackground(
        child: Container(
          decoration:
              isDark ? AppTheme.darkGradient : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
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
                child: Text(s.changeProfilePicture),
              ),

              const SizedBox(height: 24),

              TextField(
                controller: nameController,
                style: TextStyle(
                  color:
                      isDark ? Colors.white : AppTheme.textDark,
                ),
                decoration: InputDecoration(
                  labelText: s.fullName,
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
                  onPressed: () async {
                    // Save image to persistent storage if changed
                    if (_image != null) {
                      try {
                        final imageBytes = await _image!.readAsBytes();
                        await ProfileStorage.saveProfileImage(
                          imageBytes,
                          displayName: nameController.text.trim(),
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.errorSavingProfile('$e'))),
                          );
                        }
                        return;
                      }
                    }
                    
                    if (context.mounted) {
                      Navigator.pop(context, {
                        "name": nameController.text,
                        "image": _image,
                      });
                    }
                  },
                  child: Text(
                    s.saveChanges,
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
      ),
    );
  }
}