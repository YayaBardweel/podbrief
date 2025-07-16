// lib/pages/tabs/ProfileTab.dart (Updated to use UserProvider)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:intl/intl.dart'; // Make sure you have this import for date formatting

import 'package:echomind/constants/colors.dart';
import 'package:echomind/providers/user_provider.dart'; // Import your UserProvider

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  // This utility function can stay, or be moved to a helper if used elsewhere
  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    // Using intl for better date formatting. Ensure 'intl' is in your pubspec.yaml
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer to rebuild only when UserProvider notifies listeners,
    // or use Provider.of<UserProvider>(context) directly in the build method.
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        final bool isLoading = userProvider.isLoading;
        final String? errorMessage = userProvider.errorMessage;

        if (isLoading) {
          // Display a loading indicator when user data is being fetched
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage != null) {
          // Display an error message if something went wrong
          return Center(
            child: Text('Error loading profile: $errorMessage'),
          );
        }

        // If no user is logged in or data couldn't be loaded
        if (user == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No user data available. Please log in.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                // You might want to add a button to navigate to the login page here
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pushReplacementNamed(context, '/login');
                //   },
                //   child: const Text('Go to Login'),
                // ),
              ],
            ),
          );
        }

        // Now, populate the UI using data from the UserProvider
        // The `totalSummaries` and `totalListeningTime` are not part of your `UserModel`
        // as previously defined. You'll need to decide if these should be added
        // to `UserModel` or if they should be fetched separately.
        // For now, I'll set them to default or indicate they are not available from UserModel.
        // If these are user-specific stats, they should ideally be part of the UserModel
        // or a dedicated 'UserStatsProvider'.

        // Placeholder for stats if not in UserModel:
        final int totalSummaries = 0; // UserProvider's UserModel doesn't currently hold this
        final int totalListeningTime = 0; // UserProvider's UserModel doesn't currently hold this

        return ListView(
          padding: const EdgeInsets.only(top: 100), // Account for SliverAppBar
          children: [
            // Profile Header
            _buildProfileHeader(
              context,
              userProvider.getUsernameInitial(),
              user.username,
              user.email,
              _formatDate(user.registrationDate),
            ),

            const SizedBox(height: 24),

            // Stats Cards
            _buildStatsSection(totalSummaries, totalListeningTime), // Pass placeholders

            const SizedBox(height: 24),

            // Settings Section
            _buildSettingsSection(),

            const SizedBox(height: 24),

            // Account Actions
            _buildAccountActions(context), // Pass context for dialog

            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  // --- Helper Widgets (now receive data as arguments) ---

  Widget _buildProfileHeader(
      BuildContext context,
      String usernameInitial,
      String username,
      String email,
      String memberSince,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            kPrimaryColor.withOpacity(0.1),
            kPrimaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: kPrimaryColor,
                child: Text(
                  usernameInitial,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Username
          Text(
            username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 8),

          // Member Since
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Member since $memberSince',
              style: TextStyle(
                fontSize: 12,
                color: kPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(int totalSummaries, int totalListeningTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Statistics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.summarize_outlined,
                  title: 'Summaries',
                  value: '$totalSummaries', // Use the passed value
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.access_time,
                  title: 'Time Saved',
                  value: '${totalListeningTime}m', // Use the passed value
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: kPrimaryColor,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeColor: kPrimaryColor,
                  ),
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'English',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.storage_outlined,
                  title: 'Storage',
                  subtitle: 'Manage downloads',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSettingItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'Version 1.0.0',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
                _buildDivider(),
                _buildSettingItem(
                  icon: Icons.logout,
                  title: 'Sign Out',
                  textColor: Colors.red,
                  onTap: () {
                    _showSignOutDialog(context); // Pass context to the dialog
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.grey[700],
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      )
          : null,
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey[300],
      indent: 60,
      endIndent: 20,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // Use dialogContext to avoid conflicts
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(), // Use dialogContext
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Use dialogContext
                await FirebaseAuth.instance.signOut();
                // The main.dart StreamBuilder for authStateChanges will handle the navigation to /login or auth_gate
                // Remove the direct Navigator.pushReplacementNamed(context, '/login'); here
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}