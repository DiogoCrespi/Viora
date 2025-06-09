import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/repositories/preferences_repository.dart';
import '../../../core/config/supabase_config.dart';
import '../../../presentation/screens/auth/login_screen.dart';

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
    debugPrint('ProfileScreen: initState');
    _checkAuthAndLoadData();
  }

  Future<void> _checkAuthAndLoadData() async {
    debugPrint('ProfileScreen: Checking authentication...');
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      debugPrint('ProfileScreen: Current session: ${session?.user.id}');
      debugPrint('ProfileScreen: Current user: ${user?.id}');
      debugPrint('ProfileScreen: User metadata: ${user?.userMetadata}');
      debugPrint('ProfileScreen: User email: ${user?.email}');

      if (session == null || user == null) {
        debugPrint('ProfileScreen: No active session or user found');
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
      debugPrint('ProfileScreen: Session expires at: $expiresAt');
      debugPrint('ProfileScreen: Current time: $now');

      if (expiresAt != null && expiresAt < now) {
        debugPrint('ProfileScreen: Session expired');
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
      debugPrint('ProfileScreen: Error checking auth: $e');
      debugPrint('ProfileScreen: Stack trace: $stackTrace');
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
    debugPrint('ProfileScreen: Loading user data...');
    try {
      final user = _supabase.auth.currentUser;
      debugPrint('ProfileScreen: Current user: ${user?.id}');

      if (user == null) {
        debugPrint('ProfileScreen: No user found');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'No user found. Please login again.';
          });
        }
        return;
      }

      debugPrint('ProfileScreen: Fetching user preferences...');
      final preferences =
          await _preferencesRepository.getUserPreferences(user.id);
      debugPrint('ProfileScreen: Preferences loaded: ${preferences.toJson()}');

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
      debugPrint('ProfileScreen: Error loading user data: $e');
      debugPrint('ProfileScreen: Stack trace: $stackTrace');
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
      debugPrint('Error picking image: $e');
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
        debugPrint('ProfileScreen: Uploading new avatar...');
        final fileExt = _imageFile!.path.split('.').last;
        final fileName = '${user.id}/avatar.$fileExt';

        // Remove old avatar if exists
        if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
          try {
            debugPrint('ProfileScreen: Removing old avatar...');
            // Extract the file path from the current avatar URL
            final currentAvatarPath = _avatarUrl!.split('/').last;
            debugPrint(
                'ProfileScreen: Removing old avatar path: $currentAvatarPath');
            await _supabase.storage
                .from('avatars')
                .remove(['${user.id}/$currentAvatarPath']);
            debugPrint('ProfileScreen: Old avatar removed successfully');
          } catch (e) {
            debugPrint('ProfileScreen: Error removing old avatar: $e');
            // Continue with upload even if removal fails
          }
        }

        // Upload new avatar with overwrite option
        await _supabase.storage.from('avatars').upload(
              fileName,
              _imageFile!,
              fileOptions: const FileOptions(upsert: true),
            );
        newAvatarUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
        debugPrint('ProfileScreen: Avatar uploaded: $newAvatarUrl');
      }

      debugPrint('ProfileScreen: Updating avatar URL...');
      await _preferencesRepository.updateAvatarUrl(user.id, newAvatarUrl ?? '');

      debugPrint('ProfileScreen: Updating user metadata...');
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
      debugPrint('ProfileScreen: Error updating profile: $e');
      debugPrint('ProfileScreen: Stack trace: $stackTrace');
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
          debugPrint('Error loading avatar: $error');
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
                debugPrint('Error signing out: $e');
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
