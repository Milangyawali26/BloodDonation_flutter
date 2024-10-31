// ignore_for_file: prefer_const_constructors

import 'package:blood_app/constants/bloodgroups.dart';
import 'package:blood_app/constants/districts.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("blood donation app"),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text("this is homepage"),
        )
      ),
    );
  }
}
