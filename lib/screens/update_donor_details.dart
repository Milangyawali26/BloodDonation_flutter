import 'package:blood_app/constants/bloodgroups.dart';
import 'package:blood_app/firebase_Service.dart/firebase_dataBase_services.dart';
import 'package:blood_app/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../constants/province_district_localgovern_data.dart';

class UpdateDonorDetails extends StatefulWidget {
  const UpdateDonorDetails({super.key}
  );

  @override
  State<UpdateDonorDetails> createState() => _UpdateDonorDetailsState();
}

class _UpdateDonorDetailsState extends State<UpdateDonorDetails> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _dateOfBirthController = TextEditingController();

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedLocalGovernment;
  String? _selectedGender;
  String? _selectedBloodGroup;

  // List to hold the districts and local governments based on user selection
  List<String> _districts = [];
  List<String> _localGovernments = [];

// function to select date of birth
  Future<void> _selectBirthDate() async {
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text = picked.toString().split(" ")[0];
      });
    }
  }


  //function to fetch data
  void _fetchDataFromFirebase() async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    String uid = currentUser.uid;
    // Fetch the data using the uid
    DonorModel? donorData = await FirebaseDatabaseServices().getDonorDetailsFromId(uid: uid);
    
    if (donorData != null) {
      // Populate the form with existing data
      setState(() {
        _fullNameController.text = donorData.fullName ?? '';
        _phoneNumberController.text = donorData.phoneNumber ?? '';
        _dateOfBirthController.text = donorData.dateOfBirth ?? '';
        _selectedProvince = donorData.province;
        _selectedDistrict = donorData.district;
        _selectedLocalGovernment = donorData.localGovernment;
        _selectedGender = donorData.gender;
        _selectedBloodGroup = donorData.bloodGroup;
        
        // Update dependent fields like districts and local governments
        _districts = LocationData.districtMap[_selectedProvince] ?? [];
        _localGovernments = LocationData.localGovernmentMap[_selectedDistrict] ?? [];
      });
    }
  }
}
@override
void initState() {
  super.initState();
  _fetchDataFromFirebase(); // Prepopulate the form with the user's existing data
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("update a Donor profile"),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Full Name Field
                TextFormField(
                  controller: _fullNameController,
                  keyboardType: TextInputType.name,
                     inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[a-zA-Z\s]*$'),
                      ), // Allows only letters and spaces
                     ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter full name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (fullNameValue) {
                    if (fullNameValue == null || fullNameValue.trim().isEmpty) {
                      return 'Please Enter Full Name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                //phonenumber
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    } else if (value.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Province Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Province',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedProvince,
                  items: LocationData.provinces.map((String province) {
                    return DropdownMenuItem<String>(
                      value: province,
                      child: Text(province),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedProvince = newValue;
                      _districts =
                          LocationData.districtMap[_selectedProvince] ?? [];
                      _selectedDistrict = null;
                      _selectedLocalGovernment = null;
                      _localGovernments = [];
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a province' : null,
                ),
                const SizedBox(height: 10),
                // District Dropdown (dependent on province)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'District',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedDistrict,
                  items: _districts.map((String district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDistrict = newValue;
                      _localGovernments =
                          LocationData.localGovernmentMap[_selectedDistrict] ??
                              [];
                      _selectedLocalGovernment = null;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a district' : null,
                ),
                const SizedBox(height: 10),
                // Local Government Dropdown (dependent on district)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Local Government',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedLocalGovernment,
                  items: _localGovernments.map((String localGov) {
                    return DropdownMenuItem<String>(
                      value: localGov,
                      child: Text(localGov),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedLocalGovernment = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a local government' : null,
                ),
                const SizedBox(height: 10),
                //gender
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedGender,
                  items: ["Male", "Female", "Others"].map((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select your gender' : null,
                ),
                const SizedBox(
                  height: 10,
                ),
                //bloodgroup
                DropdownButtonFormField(
                  decoration: const InputDecoration(
                    labelText: 'Blood groups ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bloodtype),
                  ),
                  value: _selectedBloodGroup,
                  items: BloodGroup.bloodGroups.map((String bloodGroups) {
                    return DropdownMenuItem(
                        value: bloodGroups, child: Text(bloodGroups));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedBloodGroup = newValue;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a province' : null,
                ),
      
                const SizedBox(
                  height: 10,
                ),
                // birthdate
                TextFormField(
                  controller: _dateOfBirthController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Date of Birth',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectBirthDate();
                  },
                  validator: (value) =>
                      value == null ? 'Please select your date of birth' : null,
                ),
        const SizedBox(
                  height: 40,
                ),
                
                // Submit Button
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState != null) {
                        if (_formKey.currentState!.validate()) {
                          try {
                            User? currentUser = FirebaseAuth.instance.currentUser;
                            String uid=currentUser!.uid;
                            final donorModel = DonorModel(
                                id: currentUser.uid,
                                fullName: _fullNameController.text,
                                phoneNumber: _phoneNumberController.text,
                                dateOfBirth: _dateOfBirthController.text,
                                province: _selectedProvince,
                                district: _selectedDistrict,
                                localGovernment: _selectedLocalGovernment,
                                gender: _selectedGender,
                                bloodGroup: _selectedBloodGroup);
      
                            FirebaseDatabaseServices()
                                .updateDonorsUsingId(context:context,uid:uid,donorModel:  donorModel,);
      
                                                    
                          } catch (e) {
                            Get.snackbar('Error Occured', e.toString());
                          }
                          
      
                          // function to save data to data
                        }
                      }
                    },
                    child: const Text(
                      'Update and Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
