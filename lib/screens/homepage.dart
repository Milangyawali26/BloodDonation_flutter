// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Simulate whether the user is a donor
  bool isDonor = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Blood Donation App"),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            child: ListView(
              shrinkWrap: true, // Ensures ListView doesn't take up unnecessary space
              children: [
                ListTile(
                  title: Text("Add Request"),
                  leading: Icon(Icons.add_box),
                  onTap: () {
                       Navigator.of(context).pushNamed('/addRequest');
                  },
                ),
                ListTile(
                  title: Text("My Blood Request"),
                  leading: Icon(Icons.local_hospital),
                  onTap: () {
                    Navigator.of(context).pushNamed('/myBloodRequest');
                  },
                ),
                 // Show Donor Profile if user is a donor
                  ListTile(
                    title: Text("Donor Profile"),
                    leading: Icon(Icons.person),
                    onTap: () {
                       Navigator.of(context).pushNamed('/donorProfile');
                    },
                  ),
                  ListTile(
                    title: Text("Become Donor"),
                    leading: Icon(Icons.person_add),
                    onTap: () {
                       Navigator.of(context).pushNamed('/donorRegister');
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
