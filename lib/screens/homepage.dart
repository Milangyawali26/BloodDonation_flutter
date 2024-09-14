// ignore_for_file: prefer_const_constructors

import 'package:blood_app/constants/bloodgroups.dart';
import 'package:blood_app/constants/districts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("blood donation app"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
  
          children: [
            //find donar by district
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal:30,vertical: 8),
              child: Column(
                children: [
                  const Text(
                    "Search For donar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                 
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'District',
                    border: OutlineInputBorder()
                    ),
                    value: _selectedDistrict,
                    items: District.districts.map((String district) {
                      return DropdownMenuItem<String>(
                        value: district,
                        child: Text(district),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDistrict = newValue;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a district' : null,
                  ),
                 
                  const SizedBox(
                    height: 8,
                  ),
                  
                  DropdownButtonFormField(
                    decoration: InputDecoration(labelText: 'Blood Group',
                    border: OutlineInputBorder()
                    ),
                    items: BloodGroup.bloodGroups.map((String bloodGroup) {
                      return DropdownMenuItem<String>(
                        
                          value: bloodGroup, child: Text(bloodGroup));
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {});
                    },
                    validator: (value) =>
                        value == null ? 'please select a blood group' : null,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                  
                    width: MediaQuery.of(context).size.width*0.5,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 30.0,
                      ),
                      label: const Text(
                        ' find donors',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        ('Button Pressed');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                child: Text("become a donor",style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),),
                onPressed: () {
                  Navigator.of(context).pushNamed('/donorRegister');
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
