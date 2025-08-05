import 'dart:convert';
import 'dart:io';
import 'package:attendify/core/constants/app_colors.dart';
import 'package:attendify/data/models/models.dart';
import 'package:attendify/presentation/splash_screen.dart';
import 'package:attendify/data/local/preferences.dart';
import 'package:attendify/data/services/services.dart';
import 'package:attendify/presentation/widgets/copy_right.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<User>? _futureProfile;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _futureProfile = UserProfileService.getProfile();
    });
  }

  Future<void> _logout(BuildContext context) async {
    await Preferences.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (route) => false,
    );
  }

  Future<void> _pickAndUploadPhoto(User profile) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });
    try {
      // Perbaikan: encode ke base64 dan tambahkan header data URL
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64Photo = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Photo';
      final updated = await UserProfileService.updateProfile(photo: dataUrl);
      setState(() {
        _futureProfile = Future.value(updated);
        _isUploadingPhoto = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploadingPhoto = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update photo:  e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.text,
        foregroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, size: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () async {
              final profile = await _futureProfile;
              String editedName = profile?.name ?? '';
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Edit Name'),
                    content: TextFormField(
                      initialValue: editedName,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        editedName = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final updated =
                                await UserProfileService.updateProfile(
                                  name: editedName,
                                );
                            setState(() {
                              _futureProfile = Future.value(updated);
                            });
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to update profile: ${e.toString()}',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.text,
      body: _futureProfile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : FutureBuilder<User>(
              future: _futureProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Failed to load profile'));
                }

                final profile = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AppColors.secondary,
                            backgroundImage:
                                (profile.photo != null &&
                                    profile.photo!.isNotEmpty)
                                ? (profile.photo!.startsWith('data:image')
                                      ? null // base64 handled in child
                                      : (profile.photo!.startsWith('http')
                                            ? NetworkImage(profile.photo!)
                                            : NetworkImage(
                                                'https://appabsensi.mobileprojp.com/public/${profile.photo!}',
                                              )))
                                : null,
                            child:
                                (profile.photo == null ||
                                    profile.photo!.isEmpty)
                                ? Text(
                                    (profile.name.isNotEmpty
                                        ? profile.name[0].toUpperCase()
                                        : '?'),
                                    style: GoogleFonts.lexend(
                                      fontSize: 36,
                                      color: AppColors.text,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : (profile.photo!.startsWith('data:image')
                                      ? ClipOval(
                                          child: Image.memory(
                                            base64Decode(
                                              profile.photo!.split(',').last,
                                            ),
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.broken_image,
                                                      size: 48,
                                                      color: Colors.grey,
                                                    ),
                                          ),
                                        )
                                      : null),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _isUploadingPhoto
                                  ? null
                                  : () => _pickAndUploadPhoto(profile),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: _isUploadingPhoto
                                    ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.name,
                        style: GoogleFonts.lexend(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      ListTile(
                        leading: Icon(Icons.wc, color: AppColors.primary),
                        title: Text('Gender', style: GoogleFonts.lexend()),
                        subtitle: Text(
                          profile.jenisKelamin == 'L'
                              ? 'Male'
                              : profile.jenisKelamin == 'P'
                              ? 'Female'
                              : 'Not specified',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.redAccent),
                        title: Text(
                          'Logout',
                          style: GoogleFonts.lexend(color: Colors.redAccent),
                        ),
                        onTap: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'Logout',
                                style: GoogleFonts.lexend(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to logout?',
                                style: GoogleFonts.lexend(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.lexend(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    'Logout',
                                    style: GoogleFonts.lexend(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (shouldLogout == true) {
                            await _logout(context);
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: Colors.red.withOpacity(0.05),
                      ),
                      // Tambahkan copyright di bawah konten utama
                      const SizedBox(height: 24),
                      CopyrightText(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
