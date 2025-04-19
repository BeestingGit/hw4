import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dobController = TextEditingController();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final authService = context.read<AuthService>();
      final userData = await authService.getCurrentUserData();

      setState(() {
        _userData = userData;
        _firstNameController.text = userData?['firstName'] ?? '';
        _lastNameController.text = userData?['lastName'] ?? '';
        _dobController.text = userData?['dob'] ?? '';
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _errorMessage = 'Failed to load user data. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
        _errorMessage = '';
        _successMessage = '';
      });

      try {
        final authService = context.read<AuthService>();
        final success = await authService.updateUserProfile(
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
          dob: _dobController.text.trim(),
        );

        setState(() {
          _isSaving = false;
          if (success) {
            _successMessage = 'Profile updated successfully!';
          } else {
            _errorMessage = 'Failed to update profile. Please try again.';
          }
        });
      } catch (e) {
        print('Error updating profile: $e');
        setState(() {
          _isSaving = false;
          _errorMessage = 'Error updating profile: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue,
                          child: Text(
                            _userData != null &&
                                    _userData!['firstName'].isNotEmpty
                                ? _userData!['firstName'][0].toUpperCase()
                                : 'U',
                            style: TextStyle(fontSize: 40, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red[800]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (_successMessage.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(8),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _successMessage,
                            style: TextStyle(color: Colors.green[800]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _dobController,
                        decoration: InputDecoration(
                          labelText: 'Date of Birth (Optional)',
                          border: OutlineInputBorder(),
                          hintText: 'MM/DD/YYYY',
                        ),
                        keyboardType: TextInputType.datetime,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        child:
                            _isSaving
                                ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text('Save Profile'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
