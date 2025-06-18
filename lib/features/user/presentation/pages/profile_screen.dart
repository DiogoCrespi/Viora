import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // UserProvider will handle Supabase interactions
import 'package:viora/features/user/domain/repositories/preferences_repository.dart'; // Keep for now, for _updateProfile if not moved
// import 'package:viora/core/config/supabase_config.dart'; // UserProvider will handle Supabase interactions
import 'package:viora/features/auth/presentation/pages/login_screen.dart';
import 'package:provider/provider.dart'; // Added for Provider
import 'package:viora/features/user/presentation/providers/user_provider.dart'; // Added for UserProvider
import 'package:viora/features/user/domain/entities/app_user.dart'; // Added for AppUser
import 'package:flutter/foundation.dart'; // Added for debugPrint

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // _preferencesRepository might be used by _updateProfile, which is not in scope for this refactor part.
  // If UserProvider eventually handles all profile updates including preferences, this can be removed.
  final _preferencesRepository = PreferencesRepository();
  // final _supabase = SupabaseConfig.client; // Removed, UserProvider will handle
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _imageFile;
  String? _avatarUrl;
  bool _avatarCleared = false; // New state variable
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    if (!mounted) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final AppUser? currentUser = userProvider.currentUser;

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint(
            "ProfileScreen: User not authenticated or session expired, navigating to login.");
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Session expired. Please login again.';
        });
        Future.microtask(() {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        });
      }
    } else {
      await _loadUserData(currentUser);
    }
  }

  Future<void> _loadUserData(AppUser user) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _nameController.text = user.name;
      _emailController.text = user.email;

      final preferences =
          await _preferencesRepository.getUserPreferences(user.id);
      _avatarUrl = preferences.avatarUrl;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint("ProfileScreen: Error loading user data: $e\n$stackTrace");
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading profile data: $e';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _avatarCleared = false; // User picked a new image
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Pass current _avatarUrl to provider so it knows what to delete if a new one is uploaded or cleared.
      await userProvider.updateUserProfile(
        name: _nameController.text,
        imageFile: _imageFile,
        currentAvatarUrl:
            _avatarUrl, // Pass the current URL for deletion logic in provider
        avatarCleared: _avatarCleared,
      );

      if (mounted) {
        // After successful update, UserProvider should have updated its currentUser.
        // We can refresh local state from UserProvider.
        final updatedUser = userProvider.currentUser;
        // Assuming UserProvider also updates preferences and avatarPath is available on AppUserEntity
        // or through a specific getter in UserProvider after update.
        // For now, we'll rely on the provider to have updated its state,
        // and this screen will rebuild if it's listening to UserProvider.
        // If not listening, or if specific fields need local reset:
        setState(() {
          _isLoading = false;
          _imageFile = null; // Clear the local image file after upload
          _avatarCleared = false; // Reset clear flag
          // Potentially update _avatarUrl from userProvider.currentUser.avatarPath if available
          // For this example, we assume UserProvider's change will trigger a rebuild if this screen listens,
          // or _checkAuthAndLoadData() might be called again if we want to fully refresh.
          // For simplicity now, just show success. A full refresh might be better.
          if (updatedUser != null) {
            // This assumes avatarPath is directly on AppUserEntity and is updated by UserProvider
            // This might need adjustment based on how UserProvider exposes updated preferences/avatar.
            // Conceptual: _avatarUrl = userProvider.currentUser?.avatarPath ?? _avatarUrl;
            // Let's fetch it anew for this example or assume it's on AppUserEntity after provider update
            _avatarUrl =
                updatedUser.avatarPath; // Assuming AppUserEntity has avatarPath
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        // Optionally, refresh all data
        // _checkAuthAndLoadData();
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint("ProfileScreen: Error updating profile: $e\n$stackTrace");
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error updating profile: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  // Method to clear the selected/current avatar
  void _clearImage() {
    setState(() {
      _imageFile = null;
      _avatarUrl = null; // Visually clear it immediately
      _avatarCleared = true;
    });
  }

  Widget _buildAvatar() {
    // If an image has been picked locally, display it.
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    }
    // If no local image, but an avatar URL exists (and not cleared), display network image.
    // _avatarCleared flag is not directly used here as _avatarUrl is set to null in _clearImage.
    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return Image.network(
        _avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, size: 40);
        },
      );
    }

    return const Icon(Icons.person, size: 40);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                await userProvider.logout();
                if (mounted) {
                  // Navigate to login screen after logout
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e, stackTrace) {
                if (kDebugMode) {
                  debugPrint(
                      'ProfileScreen: Error signing out: $e\n$stackTrace');
                }
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        child: const Text('Go to Login'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            child: ClipOval(
                              child: SizedBox(
                                width: 100,
                                height: 100,
                                child: _buildAvatar(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Update Profile'),
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
    super.dispose();
  }
}
