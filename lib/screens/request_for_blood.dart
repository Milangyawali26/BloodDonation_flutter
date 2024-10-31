import 'package:blood_app/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:number_editing_controller/number_editing_controller.dart';
import '../constants/bloodgroups.dart';
import '../constants/province_district_localgovern_data.dart';
import '../firebase_authService.dart/firebase_dataBase_services.dart';

class RequestForBlood extends StatefulWidget {
  const RequestForBlood({super.key});

  @override
  State<RequestForBlood> createState() => _RequestForBloodState();
}

class _RequestForBloodState extends State<RequestForBlood> {
  final FirebaseDatabaseServices firebaseDatabaseServices =
      FirebaseDatabaseServices();

  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _contactPersonNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _hospitalNameController = TextEditingController();
  final _requiredPintController = NumberEditingTextController.integer();

  final _selectedDateController = TextEditingController();
  final _selectedTimeController = TextEditingController();
  final _caseDetailController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedLocalGovernment;
  String? _selectedGender;

  // List to hold the districts and local governments based on user selection
  List<String> _districts = [];
  List<String> _localGovernments = [];

  // function to select date
  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (_picked != null) {
      setState(() {
        _selectedDateController.text = _picked.toString().split(" ")[0];
      });
    }
  }

// function to select time
  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTimeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Blood Request"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(4),
                  padding: EdgeInsets.all(4),
                  child: const Text(
                      "Fill all the field to request required blood . "),
                ),
                Form(
                  key: _formKey,
                  child: Column(children: [
                    // patient name
                    TextFormField(
                      controller: _patientNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Patient  Full name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please Enter patient Full Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // contact person name
                    TextFormField(
                      controller: _contactPersonNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter contact person full name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please Enter contact personFull Name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // blood group
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
                    const SizedBox(height: 10),
                    //required pint of blood
                    TextFormField(
                      controller: _requiredPintController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Required Pint',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter
                            .digitsOnly // Ensures only digits are allowed
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the required pint';
                        } else if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Required pint must be a positive integer';
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
                          _localGovernments = LocationData
                                  .localGovernmentMap[_selectedDistrict] ??
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
                      validator: (value) => value == null
                          ? 'Please select a local government'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    //hospital Name
                    TextFormField(
                      controller: _hospitalNameController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter Hospital  name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please hospital Name';
                        }
                        return null;
                      },
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
                    // date
                    TextFormField(
                      controller: _selectedDateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Required Date',
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectDate();
                      },
                      validator: (value) => value == null
                          ? 'Please select your requied date '
                          : null,
                    ),
                    const SizedBox(height: 10),
                    //time
                    TextFormField(
                      controller: _selectedTimeController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Select Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      readOnly: true,
                      onTap: () {
                        _selectTime();
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please select a time'
                          : null,
                    ),
                    const SizedBox(height: 10),
                    //casedetail
                    TextFormField(
                      controller: _caseDetailController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter case detail',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please case detail';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                  ]),
                ),
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
      
                            if (currentUser != null) {
                              final requestModel = RequestModel(
                               
                                  userId: currentUser.uid,
                                  patientName: _patientNameController.text,
                                  gender:_selectedGender,
                                  contactPersonName: _contactPersonNameController.text,
                                  phoneNumber: _phoneNumberController.text,
                                  hospitalName: _hospitalNameController.text,
                                  bloodGroup: _selectedBloodGroup,
                                  requiredPint: _requiredPintController.text,
                                  caseDetail: _caseDetailController.text,
                                  province: _selectedProvince,
                                  district: _selectedDistrict,
                                  localGovernment: _selectedLocalGovernment,
                                  requiredDate:_selectedDateController.text,
                                  requiredTime: _selectedTimeController.text,
                                 
                                  
                                 
                                  );
      
                              FirebaseDatabaseServices().addRequest(
                                  requestModel: requestModel, context: context);
      
                            }
                          } catch (e) {
                            Get.snackbar('Error Occured', e.toString());
                          }
      
                          // function to save data to data
                        }
                      }
                    },
                    child: const Text(
                      'Submit',
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
