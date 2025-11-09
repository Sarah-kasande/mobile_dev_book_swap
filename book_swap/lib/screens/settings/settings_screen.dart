import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../services/sample_data_service.dart';
import '../auth/login_screen.dart';
import '../help/help_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.user?.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                authProvider.user?.email ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: authProvider.user?.emailVerified == true
                                      ? Colors.green.shade100
                                      : Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  authProvider.user?.emailVerified == true
                                      ? 'Verified'
                                      : 'Not Verified',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: authProvider.user?.emailVerified == true
                                        ? Colors.green.shade700
                                        : Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Notifications Section
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Notifications'),
                        subtitle: const Text('Receive notifications for swap offers'),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                            if (!value) {
                              _emailNotifications = false;
                              _pushNotifications = false;
                            }
                          });
                        },
                        activeColor: Colors.blue.shade600,
                      ),
                      
                      const Divider(height: 1),
                      
                      SwitchListTile(
                        title: const Text('Email Notifications'),
                        subtitle: const Text('Get notified via email'),
                        value: _emailNotifications,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                setState(() {
                                  _emailNotifications = value;
                                });
                              }
                            : null,
                        activeColor: Colors.blue.shade600,
                      ),
                      
                      const Divider(height: 1),
                      
                      SwitchListTile(
                        title: const Text('Push Notifications'),
                        subtitle: const Text('Get push notifications on your device'),
                        value: _pushNotifications,
                        onChanged: _notificationsEnabled
                            ? (value) {
                                setState(() {
                                  _pushNotifications = value;
                                });
                              }
                            : null,
                        activeColor: Colors.blue.shade600,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // App Info Section
                Text(
                  'App Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                        ),
                        title: const Text('About BookSwap'),
                        subtitle: const Text('Version 1.0.0'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showAboutDialog();
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      ListTile(
                        leading: Icon(
                          Icons.help_outline,
                          color: Colors.blue.shade600,
                        ),
                        title: const Text('Help & Support'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showHelpDialog();
                        },
                      ),
                      
                      const Divider(height: 1),
                      
                      ListTile(
                        leading: Icon(
                          Icons.privacy_tip_outlined,
                          color: Colors.blue.shade600,
                        ),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showPrivacyDialog();
                        },
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Developer Options Section
                Text(
                  'Developer Options',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.library_books,
                          color: Colors.green.shade600,
                        ),
                        title: const Text('Add Sample Books'),
                        subtitle: const Text('Populate database with sample books and images'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _addSampleBooks,
                      ),
                      
                      const Divider(height: 1),
                      
                      ListTile(
                        leading: Icon(
                          Icons.book,
                          color: Colors.purple.shade600,
                        ),
                        title: const Text('Add Basic Books'),
                        subtitle: const Text('Add books without images (simpler)'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _addBasicBooks,
                      ),
                      
                      const Divider(height: 1),
                      
                      ListTile(
                        leading: Icon(
                          Icons.add_box,
                          color: Colors.blue.shade600,
                        ),
                        title: const Text('Add More Books'),
                        subtitle: const Text('Add additional sample books'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _addAdditionalBooks,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About BookSwap'),
        content: const Text(
          'BookSwap is a platform for students to exchange textbooks with each other. '
          'Find the books you need and swap them with other students in your community.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpScreen(),
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text(
          'Your privacy is important to us. We collect only the necessary information '
          'to provide our book swapping service. Your personal information is never '
          'shared with third parties without your consent.\n\n'
          'For the full privacy policy, visit our website.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _addBasicBooks() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Adding basic books...'),
          ],
        ),
      ),
    );

    try {
      await SampleDataService.addBasicSampleBooks();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Refresh book list
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        await bookProvider.refreshAllBooks();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Basic books added successfully!'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding basic books: $e'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _addSampleBooks() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Adding sample books...'),
          ],
        ),
      ),
    );

    try {
      await SampleDataService.addSampleBooks();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Refresh book list
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        await bookProvider.refreshAllBooks();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sample books added successfully!'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding sample books: $e'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _addAdditionalBooks() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Adding additional books...'),
          ],
        ),
      ),
    );

    try {
      await SampleDataService.addAdditionalBooks();
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Refresh book list
        final bookProvider = Provider.of<BookProvider>(context, listen: false);
        await bookProvider.refreshAllBooks();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Additional books added successfully!'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding additional books: $e'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}