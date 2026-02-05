import 'package:flutter/material.dart';
import 'package:thrivewithms/constants/constants.dart';
import 'package:thrivewithms/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:thrivewithms/screens/login_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isEditing = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  // Controllers
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  DateTime? _dateOfBirth;
  String _gender = 'Not Specified';

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userId = await ApiService.getUserId();
      final userData = await ApiService.fetchUserData(userId);

      setState(() {
        _firstNameController.text = userData['firstname'] ?? '';
        _lastNameController.text = userData['lastname'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _dateOfBirth = userData['dateOfBirth'] != null
            ? DateTime.parse(userData['dateOfBirth'])
            : null;
        _gender = userData['gender'] ?? 'Not Specified';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = await ApiService.getUserId();
      final updateData = {
        'firstname': _firstNameController.text.trim(),
        'lastname': _lastNameController.text.trim(),
        'gender': _gender,
      };

      if (_dateOfBirth != null) {
        updateData['dateOfBirth'] = _dateOfBirth!.toIso8601String();
      }

      // Handle password update separately from profile update
      if (_newPasswordController.text.isNotEmpty) {
        try {
          await ApiService.changePassword(
            _currentPasswordController.text,
            _newPasswordController.text,
          );

          // If we reach here, password was changed successfully
          // The API service will handle logout, so we should navigate to login screen
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
          return; // Exit early as we're logging out
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to change password: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return; // Exit early on password change failure
        }
      }

      // If no password change, just update profile
      await ApiService.updateUser(userId, updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: textNavy,
          ),
        );
        setState(() {
          _isEditing = false;
          _currentPasswordController.clear();
          _newPasswordController.clear();
        });

        // Pop and send back the updated firstname
        Navigator.pop(context, _firstNameController.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Profile Settings',
          style: TextStyle(
            color: textNavy,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: textNavy),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50, // Very light orange at top
              Colors.white,
            ],
            stops: const [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Basic Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _firstNameController,
                              enabled: _isEditing,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'First name is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _lastNameController,
                              enabled: _isEditing,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Last name is required'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                filled: true,
                                fillColor: Colors.grey[100],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            if (_isEditing) ...[
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _currentPasswordController,
                                obscureText: _obscureCurrentPassword,
                                decoration: InputDecoration(
                                  labelText: 'Current Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureCurrentPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureCurrentPassword =
                                            !_obscureCurrentPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (_newPasswordController.text.isNotEmpty &&
                                      (value?.isEmpty ?? true)) {
                                    return 'Current password is required to set new password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _newPasswordController,
                                obscureText: _obscureNewPassword,
                                decoration: InputDecoration(
                                  labelText: 'New Password (optional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNewPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword =
                                            !_obscureNewPassword;
                                      });
                                    },
                                  ),
                                  helperText:
                                      'Must be at least 8 characters with letters and numbers',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return null;
                                  if (value.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  if (!value.contains(RegExp(r'[a-zA-Z]'))) {
                                    return 'Password must contain at least one letter';
                                  }
                                  if (!value.contains(RegExp(r'[0-9]'))) {
                                    return 'Password must contain at least one number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            const SizedBox(height: 32),
                            const Text(
                              'Additional Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textNavy,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              title: const Text('Date of Birth'),
                              subtitle: Text(
                                _dateOfBirth != null
                                    ? DateFormat('MMMM d, yyyy')
                                        .format(_dateOfBirth!)
                                    : 'Not set',
                              ),
                              trailing: _isEditing
                                  ? Icon(
                                      Icons.calendar_today,
                                      color: Colors.orange.shade600,
                                    )
                                  : null,
                              onTap: _isEditing
                                  ? () => _selectDate(context)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_isEditing)
                              DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Not Specified',
                                    child: Text('Prefer not to say'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Male',
                                    child: Text('Male'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Female',
                                    child: Text('Female'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _gender = value);
                                  }
                                },
                              )
                            else
                              ListTile(
                                title: const Text('Gender'),
                                subtitle: Text(_gender),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),

                            // Add logout button at the bottom
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: ElevatedButton(
                                onPressed: () async {
                                  // Show confirmation dialog
                                  final shouldLogout = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                        'Logout',
                                        style: TextStyle(color: textNavy),
                                      ),
                                      content: const Text(
                                        'Are you sure you want to logout?',
                                        style: TextStyle(color: textNavy),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: textNavy,
                                          ),
                                          child: const Text(
                                            'Logout',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (shouldLogout == true) {
                                    await ApiService.logout();
                                    if (mounted) {
                                      // Navigate to login screen and clear all previous routes
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: textNavy,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
