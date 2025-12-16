import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/providers/auth_provider.dart';
import '../../config/routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _smsNotifications = true;
  bool _darkMode = false;
  bool _privateAccount = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          // Account Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to change password
            },
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Change Email'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to change email
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lock_person_outlined),
            title: const Text('Private Account'),
            subtitle: const Text('Only followers can see your posts'),
            value: _privateAccount,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _privateAccount = value;
              });
            },
          ),
          const Divider(),
          // Notifications Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Push Notifications'),
            value: _pushNotifications,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.email_outlined),
            title: const Text('Email Notifications'),
            value: _emailNotifications,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.sms_outlined),
            title: const Text('SMS Notifications'),
            value: _smsNotifications,
            activeColor: AppColors.primary,
            onChanged: (value) {
              setState(() {
                _smsNotifications = value;
              });
            },
          ),
          const Divider(),
          // Appearance Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Dark Mode'),
            subtitle: const Text('Coming soon'),
            value: _darkMode,
            activeColor: AppColors.primary,
            onChanged: null, // Disabled for now
          ),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: const Text('Language'),
            subtitle: const Text('English (US)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show language selector
            },
          ),
          const Divider(),
          // Privacy Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Privacy & Security',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Blocked Accounts'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to blocked accounts
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show terms of service
            },
          ),
          const Divider(),
          // Support Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Support',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help Center'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to help center
            },
          ),
          ListTile(
            leading: const Icon(Icons.report_outlined),
            title: const Text('Report a Problem'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to report problem
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Show about dialog
            },
          ),
          const Divider(),
          // Logout Section
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await Provider.of<AuthProvider>(context, listen: false).logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, AppRoutes.login);
                          }
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Delete Account
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'This action cannot be undone. All your data will be permanently deleted.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement account deletion
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}