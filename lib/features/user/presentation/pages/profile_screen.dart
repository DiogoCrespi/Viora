import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:viora/features/user/domain/repositories/preferences_repository.dart';
import 'package:viora/core/config/supabase_config.dart';
import 'package:viora/features/auth/presentation/pages/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _preferencesRepository = PreferencesRepository();
  final _supabase = SupabaseConfig.client;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _imageFile;
  String? _avatarUrl;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      if (session == null || user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Session expired. Please login again.';
          });
          // Use Future.microtask to schedule navigation after the build
          Future.microtask(() {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          });
        }
        return;
      }

      // Verificar se a sessão está expirada
      final now =
          DateTime.now().millisecondsSinceEpoch ~/ 1000; // Convert to seconds
      final expiresAt = session.expiresAt;

      if (expiresAt != null && expiresAt < now) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Session expired. Please login again.';
          });
          // Use Future.microtask to schedule navigation after the build
          Future.microtask(() {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          });
        }
        return;
      }

      await _loadUserData();
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error checking authentication: $e';
        });
        // Use Future.microtask to schedule navigation after the build
        Future.microtask(() {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No user found. Please login again.';
          });
        }
        return;
      }

      final preferences =
          await _preferencesRepository.getUserPreferences(user.id);

      if (mounted) {
        setState(() {
          _nameController.text = user.userMetadata?['name'] ?? '';
          _emailController.text = user.email ?? '';
          _avatarUrl = preferences.avatarUrl;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading profile: $e';
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
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('No user found');
      }

      String? newAvatarUrl = _avatarUrl;

      if (_imageFile != null) {
        // Remove old avatar if exists
        if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
          try {
            // Extract the file path from the current avatar URL
            final currentAvatarPath = _avatarUrl!.split('/').last;
            await _supabase.storage
                .from('avatars')
                .remove(['${user.id}/$currentAvatarPath']);
          } catch (e) {
            // Continue with upload even if removal fails
          }
        }

        // Upload new avatar with overwrite option
        final fileExt = _imageFile!.path.split('.').last;
        final fileName = '${user.id}/avatar.$fileExt';
        await _supabase.storage.from('avatars').upload(
              fileName,
              _imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );
        newAvatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      await _preferencesRepository.updateAvatarUrl(user.id, newAvatarUrl ?? '');

      await _supabase.auth.updateUser(
        UserAttributes(
          data: {'name': _nameController.text},
        ),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _avatarUrl = newAvatarUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (e, stackTrace) {
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

  Widget _buildAvatar() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    }

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
                await _supabase.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (e) {
                print('Error signing out: $e');
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
