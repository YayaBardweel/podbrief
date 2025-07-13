import 'package:echomind/constants/colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _username;
  bool _isLoadingUser = true;
  int _selectedIndex = 0;

  final List<Map<String, String>> _summaries = [
    {
      'title': 'The Future of AI',
      'date': 'July 10, 2025',
      'preview': 'An in-depth look at upcoming AI trends and their societal impact...',
    },
    {
      'title': 'Healthy Habits for Busy Professionals',
      'date': 'July 8, 2025',
      'preview': 'Tips and tricks for maintaining well-being amidst a hectic schedule...',
    },
    {
      'title': 'Understanding Blockchain Technology',
      'date': 'July 5, 2025',
      'preview': 'Demystifying the core concepts of blockchain and its applications...',
    },
    {
      'title': 'Space Exploration: Next Frontiers',
      'date': 'July 3, 2025',
      'preview': 'Discovering the latest advancements and future plans in space travel...',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();
        setState(() {
          _username = data?['username'] ?? 'User';
          _isLoadingUser = false;
        });
      } catch (e) {
        print('❌ Error fetching username: $e');
        setState(() {
          _username = 'User';
          _isLoadingUser = false;
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    String message;
    switch (index) {
      case 0:
        message = 'Home Selected';
        break;
      case 1:
        message = 'History Selected';
        break;
      case 2:
        message = 'Create Summary Selected';
        break;
      case 3:
        message = 'Profile Selected';
        break;
      default:
        message = '';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. SliverAppBar with Glassmorphism
          SliverAppBar(
            expandedHeight: 70.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    centerTitle: false,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: kTextColorLight),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Menu coming soon!')),
                          ),
                        ),
                        const Text(
                          "PodBrief",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: kTextColorLight,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search, color: kTextColorLight),
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Search coming soon!')),
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 20,
                              child: Text(
                                _username?.substring(0, 1).toUpperCase() ?? 'U',
                                style: TextStyle(
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

          // 2. Welcome Header
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor.withOpacity(0.9), kAccentColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isLoadingUser
                            ? 'Good Morning...'
                            : 'Good Morning, $_username!',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: kTextColorLight,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Summarize your podcasts in seconds.',
                        style: TextStyle(
                          fontSize: 16,
                          color: kTextColorLight.withOpacity(0.8),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Add Transcript clicked!')),
                          ),
                          icon: const Icon(Icons.add, color: kPrimaryColor),
                          label: const Text(
                            'Add Transcript',
                            style: TextStyle(
                                fontSize: 16.0,
                                color: kPrimaryColor,
                                fontFamily: 'Poppins'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Transcript Upload Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: InkWell(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tap to input/paste transcript!')),
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic, color: kPrimaryColor, size: 35),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              'Tap to input or paste podcast transcript',
                              style: TextStyle(
                                fontSize: 17,
                                color: kTextColorDark,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 4. Recent Summaries
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Recent Summaries',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kTextColorDark,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: _summaries.map((summary) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              summary['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: kPrimaryColor,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Summarized on: ${summary['date']}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              summary['preview']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: kTextColorDark.withOpacity(0.8),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.visibility, color: kPrimaryColor),
                                  label: Text('View',
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontFamily: 'Poppins')),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {},
                                  icon: Icon(Icons.share, color: kPrimaryColor),
                                  label: Text('Share',
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontFamily: 'Poppins')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),

      // 5. Bottom Navigation Bar
      bottomNavigationBar: Container(
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
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: kPrimaryColor,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Create'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            unselectedLabelStyle: TextStyle(fontFamily: 'Poppins'),
          ),
        ),
      ),
    );
  }
}
