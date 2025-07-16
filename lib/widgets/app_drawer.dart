// lib/widgets/app_drawer.dart (Revised)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:echomind/providers/user_provider.dart';
import 'package:echomind/providers/root_page_controller.dart'; // Import
import 'package:echomind/constants/colors.dart';

class AppDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const AppDrawer({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final rootPageController = Provider.of<RootPageController>(context, listen: false); // Use listen: false here

    final user = userProvider.currentUser;
    final bool isLoading = userProvider.isLoading;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: kPrimaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: isLoading
                      ? const CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor)
                      : Text(
                    userProvider.getUsernameInitial(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                isLoading
                    ? const Text('Loading user...', style: TextStyle(color: Colors.white70))
                    : Text(
                  user?.username ?? 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isLoading
                    ? const SizedBox.shrink()
                    : Text(
                  user?.email ?? 'No email',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              rootPageController.navigateToTab(0); // Use the controller
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () {
              Navigator.pop(context);
              rootPageController.navigateToTab(1); // Use the controller
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Create'),
            onTap: () {
              Navigator.pop(context);
              rootPageController.navigateToTab(2); // Use the controller
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              rootPageController.navigateToTab(3); // Use the controller
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}