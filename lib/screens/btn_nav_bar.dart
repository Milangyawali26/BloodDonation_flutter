import 'package:blood_app/screens/homepage.dart';
import 'package:blood_app/screens/profile.dart';
import 'package:flutter/material.dart';



class BtmNavigationBar extends StatefulWidget {
    
  const BtmNavigationBar({super.key, });

  @override
  State<BtmNavigationBar> createState() => _BtmNavigationBarState();
}

class _BtmNavigationBarState extends State<BtmNavigationBar> {
  int _selectedIndex=0;

  final List<Widget> _pages=[
   HomePage(),
   HomePage(),
   HomePage(),
   Profile(),

  ];
  
  void _onItemTapped(int index){
    setState((){
      _selectedIndex=index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(

        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'home'),
          
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'profile'),
        ],
        currentIndex: _selectedIndex,
        onTap:_onItemTapped,
        
      ),
     
    );
  }
}

