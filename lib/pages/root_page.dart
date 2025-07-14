import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echomind/pages/tabs/CreateTab.dart';
import 'package:echomind/pages/tabs/HistoryTab.dart';
import 'package:echomind/pages/tabs/HomeTab.dart';
import 'package:echomind/pages/tabs/ProfileTab.dart';
import 'package:echomind/widgets/app_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:echomind/constants/colors.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  String? _username;
  bool _isLoadingUser = true;

  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _username = 'User';
        _isLoadingUser = false;
      });
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _username = doc.data()?['username'] ?? (user.displayName ?? 'User');
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() {
        _username = user.displayName ?? 'User';
        _isLoadingUser = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        username: _username ?? 'User',
        onLogout: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            _buildSliverAppBar(context), // Our SliverAppBar goes here
          ];
        },
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Keep this for tab switching
          onPageChanged: (i) => setState(() => _currentIndex = i),
          children: [
            // Ensure your tabs return scrollable widgets and have PageStorageKeys
            HomeTab(key: const PageStorageKey<String>('HomeTabScroll'), username: _username ?? 'User', isLoading: _isLoadingUser),
            HistoryTab(key: const PageStorageKey<String>('HistoryTabScroll')),
            CreateTab(key: const PageStorageKey<String>('CreateTabScroll')),
            ProfileTab(key: const PageStorageKey<String>('ProfileTabScroll')),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 90, // Height when expanded
      floating: true, // Appears when scrolling up
      pinned: true, // Stays visible at the top when collapsed
      snap: true, // Snaps into view
      stretch: true, // Allows stretching beyond expandedHeight
      systemOverlayStyle: SystemUiOverlayStyle.light, // For light status bar icons
      backgroundColor: Colors.transparent, // Make SliverAppBar itself transparent
      // IMPORTANT: Set this to false to prevent the default menu icon
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
              background: Container(color: Colors.transparent), // The actual background for the blur effect
              titlePadding: EdgeInsets.zero, // Remove default title padding
              centerTitle: false,
              // The `title` of FlexibleSpaceBar is what appears in the collapsed state.
              // We're using it to house our custom row, ensuring it respects SafeArea.
              title: SafeArea(
                // Use a Builder to get a context that can find the Scaffold
                // if you're using Scaffold.of(context) directly within the title.
                // However, since this is in _buildSliverAppBar, `context` should be fine.
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12, left: 24, right: 24), // Adjust padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Your custom menu icon that opens the drawer
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () {
                          Scaffold.of(context).openDrawer(); // This opens the drawer
                        },
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
                          if (_currentIndex == 0 || _currentIndex == 1)
                            IconButton(
                              icon: const Icon(Icons.search, color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Search tapped!")),
                                );
                              },
                            ),
                          const SizedBox(width: 8), // Space between search and avatar
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 14,
                            child: Text(
                              (_username ?? 'U').substring(0, 1).toUpperCase(),
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

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTapped,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Create'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}