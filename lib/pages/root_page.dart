// lib/pages/root_page.dart (Revised to use Providers)
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // Import Provider

import 'package:echomind/constants/colors.dart';
import 'package:echomind/pages/tabs/CreateTab.dart';
import 'package:echomind/pages/tabs/HistoryTab.dart';
import 'package:echomind/pages/tabs/HomeTab.dart';
import 'package:echomind/pages/tabs/ProfileTab.dart';
import 'package:echomind/services/summary_search_delegate.dart';
import 'package:echomind/widgets/app_drawer.dart';
import 'package:echomind/widgets/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:echomind/providers/user_provider.dart'; // Import your UserProvider
import 'package:echomind/providers/root_page_controller.dart'; // Import your RootPageController
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // For logout

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final PageController _pageController = PageController();
  // _currentIndex will now be kept in sync with RootPageController
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Listen to RootPageController for navigation changes initiated by AppDrawer
    Provider.of<RootPageController>(context, listen: false).addListener(_handleRootPageNavigation);
  }

  void _handleRootPageNavigation() {
    // Get the index from the controller
    final newIndex = Provider.of<RootPageController>(context, listen: false).currentIndex;
    // Only update if the index has actually changed to avoid unnecessary rebuilds
    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
      _pageController.jumpToPage(newIndex);
    }
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed to prevent memory leaks
    Provider.of<RootPageController>(context, listen: false).removeListener(_handleRootPageNavigation);
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    // When bottom nav bar is tapped, update the RootPageController,
    // which in turn will update _currentIndex via the listener
    Provider.of<RootPageController>(context, listen: false).navigateToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    // Access UserProvider to get user data
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      drawer: AppDrawer(
        // AppDrawer will now get its user info directly from Provider
        onLogout: () async {
          try {
            await firebase_auth.FirebaseAuth.instance.signOut();
            // The StreamBuilder in main.dart will handle navigation to auth_gate
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Logout failed: ${e.toString()}')),
              );
            }
          }
        },
      ),
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            _buildSliverAppBar(
              context,
              userProvider.getUsernameInitial(), // Use initial from UserProvider
              userProvider.isLoading, // Use loading state from UserProvider
            ),
          ];
        },
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Disallow manual swiping between tabs
          onPageChanged: (i) => setState(() => _currentIndex = i), // Keep local index in sync if needed, though RootPageController is primary
          children: [
            HomeTab(
              username: userProvider.getDisplayName(), // Pass from provider
              isLoading: userProvider.isLoading, // Pass from provider
              onNavigateToCreate: _navigateToCreateTab, // This callback remains for HomeTab's internal navigation
            ),
            HistoryTab(key: const PageStorageKey<String>('HistoryTabScroll')),
            CreateTab(key: const PageStorageKey<String>('CreateTabScroll')),
            ProfileTab(key: const PageStorageKey<String>('ProfileTabScroll')), // ProfileTab will use Provider directly
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex, // Use local _currentIndex for selected state
        onTap: _onNavTapped, // Update RootPageController on tap
      ),
    );
  }

  // This method can remain if HomeTab specifically needs to trigger CreateTab from within itself.
  void _navigateToCreateTab() {
    _pageController.jumpToPage(2);
    setState(() => _currentIndex = 2);
    Provider.of<RootPageController>(context, listen: false).navigateToTab(2); // Also update the controller
  }

  Widget _buildSliverAppBar(BuildContext context, String usernameInitial, bool isLoadingUser) {
    // This widget now takes isLoadingUser directly from the provider
    return SliverAppBar(
      expandedHeight: 90,
      floating: true,
      pinned: true,
      snap: true,
      stretch: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.7),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: FlexibleSpaceBar(
              background: Container(color: Colors.transparent),
              titlePadding: EdgeInsets.zero,
              centerTitle: false,
              title: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12, left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                      const Text(
                        'PodBrief',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Row(
                        children: [
                          if (_currentIndex == 0 || _currentIndex == 1) // Still uses local index for conditional search button
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.white),
                              onPressed: () => showSearch(
                                context: context,
                                delegate: SummarySearchDelegate(),
                              ),
                            ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 14,
                            child: isLoadingUser // Use the passed isLoadingUser
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimaryColor,
                              ),
                            )
                                : Text(
                              usernameInitial, // Use the passed usernameInitial
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}