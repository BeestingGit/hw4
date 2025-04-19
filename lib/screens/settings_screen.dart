import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isUpdatingEmail = false;
  bool _isUpdatingPassword = false;

  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _newEmailController = TextEditingController();
  final _currentPasswordForEmailController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  String _emailErrorMessage = '';
  String _emailSuccessMessage = '';
  String _passwordErrorMessage = '';
  String _passwordSuccessMessage = '';

  bool _isLoading = false;

  @override
  void dispose() {
    _newEmailController.dispose();
    _currentPasswordForEmailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    if (_emailFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _emailErrorMessage = '';
        _emailSuccessMessage = '';
      });

      try {
        final authService = context.read<AuthService>();
        final success = await authService.updateEmail(
          _newEmailController.text.trim(),
          _currentPasswordForEmailController.text,
        );

        setState(() {
          _isLoading = false;
          if (success) {
            _emailSuccessMessage = 'Email updated successfully!';
            _newEmailController.clear();
            _currentPasswordForEmailController.clear();
            _isUpdatingEmail = false;
          } else {
            _emailErrorMessage =
                'Failed to update email. Please check your password and try again.';
          }
        });
      } catch (e) {
        print('Error updating email: $e');
        setState(() {
          _isLoading = false;
          _emailErrorMessage = 'Error updating email: $e';
        });
      }
    }
  }

  Future<void> _updatePassword() async {
    if (_passwordFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _passwordErrorMessage = '';
        _passwordSuccessMessage = '';
      });

      try {
        final authService = context.read<AuthService>();
        final success = await authService.updatePassword(
          _currentPasswordController.text,
          _newPasswordController.text,
        );

        setState(() {
          _isLoading = false;
          if (success) {
            _passwordSuccessMessage = 'Password updated successfully!';
            _currentPasswordController.clear();
            _newPasswordController.clear();
            _confirmNewPasswordController.clear();
            _isUpdatingPassword = false;
          } else {
            _passwordErrorMessage =
                'Failed to update password. Please check your current password and try again.';
          }
        });
      } catch (e) {
        print('Error updating password: $e');
        setState(() {
          _isLoading = false;
          _passwordErrorMessage = 'Error updating password: $e';
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await context.read<AuthService>().signOut();
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Email Settings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isUpdatingEmail ? Icons.close : Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isUpdatingEmail = !_isUpdatingEmail;
                                      _emailErrorMessage = '';
                                      _emailSuccessMessage = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_isUpdatingEmail) ...[
                              SizedBox(height: 16),
                              if (_emailErrorMessage.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _emailErrorMessage,
                                    style: TextStyle(color: Colors.red[800]),
                                  ),
                                ),
                              if (_emailSuccessMessage.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _emailSuccessMessage,
                                    style: TextStyle(color: Colors.green[800]),
                                  ),
                                ),
                              Form(
                                key: _emailFormKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _newEmailController,
                                      decoration: InputDecoration(
                                        labelText: 'New Email',
                                        border: OutlineInputBorder(),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a new email';
                                        }
                                        if (!value.contains('@') ||
                                            !value.contains('.')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller:
                                          _currentPasswordForEmailController,
                                      decoration: InputDecoration(
                                        labelText: 'Current Password',
                                        border: OutlineInputBorder(),
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your current password';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _updateEmail,
                                      child: Text('Update Email'),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Password Settings',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _isUpdatingPassword
                                        ? Icons.close
                                        : Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isUpdatingPassword =
                                          !_isUpdatingPassword;
                                      _passwordErrorMessage = '';
                                      _passwordSuccessMessage = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                            if (_isUpdatingPassword) ...[
                              SizedBox(height: 16),
                              if (_passwordErrorMessage.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _passwordErrorMessage,
                                    style: TextStyle(color: Colors.red[800]),
                                  ),
                                ),
                              if (_passwordSuccessMessage.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(8),
                                  margin: EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _passwordSuccessMessage,
                                    style: TextStyle(color: Colors.green[800]),
                                  ),
                                ),
                              Form(
                                key: _passwordFormKey,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _currentPasswordController,
                                      decoration: InputDecoration(
                                        labelText: 'Current Password',
                                        border: OutlineInputBorder(),
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your current password';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller: _newPasswordController,
                                      decoration: InputDecoration(
                                        labelText: 'New Password',
                                        border: OutlineInputBorder(),
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a new password';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters long';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller: _confirmNewPasswordController,
                                      decoration: InputDecoration(
                                        labelText: 'Confirm New Password',
                                        border: OutlineInputBorder(),
                                      ),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your new password';
                                        }
                                        if (value !=
                                            _newPasswordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _updatePassword,
                                      child: Text('Update Password'),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: Icon(Icons.logout),
                      label: Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _logout,
                    ),
                  ],
                ),
              ),
    );
  }
}
