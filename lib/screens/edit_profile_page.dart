import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../data/profile_storage.dart';
import '../l10n/app_strings.dart';
import '../theme/app_theme.dart';
import '../widgets/soft_background.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    required this.currentName,
    super.key,
    this.currentImage,
  });
  final String currentName;
  final XFile? currentImage;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  XFile? _image;
  Uint8List? _savedImageBytes;
  bool _loadingSavedImage = true;
  bool _imageChanged = false;
  bool _isSaving = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.currentName);
    _image = widget.currentImage;
    _loadSavedImageFallback();
  }

  Future<void> _loadSavedImageFallback() async {
    try {
      final savedImage = await ProfileStorage.loadProfileImage();
      if (!mounted) {
        return;
      }
      setState(() {
        _savedImageBytes = savedImage;
        _loadingSavedImage = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingSavedImage = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
      maxHeight: 1600,
    );

    if (pickedFile == null) {
      return;
    }

    if (kIsWeb) {
      setState(() {
        _image = pickedFile;
        _imageChanged = true;
      });
      return;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 72,
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
        _imageChanged = true;
      });
    }
  }

  /// ✅ ตัวนี้สำคัญมาก
  Widget _buildProfileImage() {
    if (_image == null && _savedImageBytes == null && _loadingSavedImage) {
      return const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
      );
    }

    if (_image == null && _savedImageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _savedImageBytes!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_image == null) {
      return const Icon(
        Icons.person,
        size: 50,
        color: AppTheme.primary,
      );
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
          if (_savedImageBytes != null) {
            return ClipOval(
              child: Image.memory(
                _savedImageBytes!,
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
    final imageFile = File(_image!.path);
    if (!imageFile.existsSync() && _savedImageBytes != null) {
      return ClipOval(
        child: Image.memory(
          _savedImageBytes!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipOval(
      child: Image.file(
        imageFile,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          decoration: isDark ? AppTheme.darkGradient : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
            child: Column(
              children: [
                /// ✅ แก้ตรงนี้
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: isDark ? Colors.white10 : Colors.white,
                    child: _buildProfileImage(),
                  ),
                ),

                TextButton(
                  onPressed: _pickImage,
                  child: Text(s.changeProfilePicture),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: nameController,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.textDark,
                  ),
                  decoration: InputDecoration(
                    labelText: s.fullName,
                    filled: true,
                    fillColor:
                        isDark ? AppTheme.inputDark : AppTheme.inputLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            setState(() {
                              _isSaving = true;
                            });
                            // Let Flutter paint the loading spinner before heavy work starts.
                            await Future<void>.delayed(
                              const Duration(milliseconds: 16),
                            );

                            // Save image only when user actually changed it.
                            if (_imageChanged && _image != null) {
                              try {
                                final imageBytes = await _image!.readAsBytes();
                                await ProfileStorage.saveProfileImage(
                                  imageBytes,
                                  displayName: nameController.text.trim(),
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(s.errorSavingProfile('$e'))),
                                  );
                                }
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                                return;
                              }
                            } else {
                              try {
                                await ProfileStorage.saveDisplayName(
                                  nameController.text.trim(),
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(s.errorSavingProfile('$e'))),
                                  );
                                }
                                if (mounted) {
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                                return;
                              }
                            }

                            if (context.mounted) {
                              Navigator.pop(context, {
                                'name': nameController.text,
                                'image': _image,
                              });
                            }
                          },
                    child: _isSaving
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                s.saveChanges,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            s.saveChanges,
                            style: const TextStyle(
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
