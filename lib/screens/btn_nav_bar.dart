import 'package:blood_app/screens/allBloodRequest.dart';

import 'package:blood_app/screens/homepage.dart';
import 'package:blood_app/screens/profile.dart';
import 'package:blood_app/screens/search_donors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BtmNavigationBar extends StatefulWidget {
  const BtmNavigationBar({
    super.key,
  });

  @override
  State<BtmNavigationBar> createState() => _BtmNavigationBarState();
}

class _BtmNavigationBarState extends State<BtmNavigationBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    AllBloodRequest(),
    Searchdonors(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true, // Always show selected labels
          showUnselectedLabels: true, // Always show unselected labels
      
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.doc_text), label: 'all request'),
            BottomNavigationBarItem(
                icon: Icon(Icons.search), label: 'search donors'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
