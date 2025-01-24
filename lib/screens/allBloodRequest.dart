import 'package:blood_app/firebase_authService.dart/firebase_dataBase_services.dart';
import 'package:blood_app/model/user_model.dart';
import 'package:flutter/material.dart';
// For date formatting
import '../constants/bloodgroups.dart';
import '../constants/province_district_localgovern_data.dart';

class AllBloodRequest extends StatefulWidget {
  const AllBloodRequest({super.key});

  @override
  State<AllBloodRequest> createState() => _AllBloodRequestState();
}

class _AllBloodRequestState extends State<AllBloodRequest>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String? _selectedProvince;
  String? _selectedDistrict;
  String? _selectedLocalGovernment;
  String? _selectedBloodGroup;
  List<String> _districts = [];
  List<String> _localGovernments = [];
  List<RequestModel> filteredBloodRequests = [];
  List<RequestModel> todayRequests = [];
  List<RequestModel> tomorrowRequests = [];
  List<RequestModel> laterDaysRequests = [];

  final FirebaseDatabaseServices firebaseDatabaseServices =
      FirebaseDatabaseServices();

  // Fetch and filter blood requests based on the selected filters
  Future<void> _fetchAndFilterBloodRequest() async {
    List<RequestModel> bloodRequests =
        await firebaseDatabaseServices.getAllBloodRequest();
    _applyFilters(bloodRequests);
  }

  void _applyFilters(List<RequestModel> bloodRequests) {
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime tomorrow = today.add(const Duration(days: 1));

    setState(() {
      filteredBloodRequests = bloodRequests.where((bloodRequest) {
        bool matchesProvince = _selectedProvince == null ||
            bloodRequest.province == _selectedProvince;
        bool matchesDistrict = _selectedDistrict == null ||
            bloodRequest.district == _selectedDistrict;
        bool matchesLocalGovernment = _selectedLocalGovernment == null ||
            bloodRequest.localGovernment == _selectedLocalGovernment;
        bool matchesBloodGroup = _selectedBloodGroup == null ||
            bloodRequest.bloodGroup == _selectedBloodGroup;

        return matchesProvince &&
            matchesDistrict &&
            matchesLocalGovernment &&
            matchesBloodGroup;
      }).toList();

      // Clear existing lists to avoid appending duplicates
      todayRequests.clear();
      tomorrowRequests.clear();
      laterDaysRequests.clear();

      // Populate todayRequests, tomorrowRequests, and laterDaysRequests
      todayRequests.addAll(filteredBloodRequests.where((request) =>
          DateTime.parse(request.requiredDate!).isAtSameMomentAs(today)));

      tomorrowRequests.addAll(filteredBloodRequests.where((request) =>
          DateTime.parse(request.requiredDate!).isAtSameMomentAs(tomorrow)));

      laterDaysRequests.addAll(filteredBloodRequests.where((request) =>
          DateTime.parse(request.requiredDate!).isAfter(tomorrow)));
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAndFilterBloodRequest();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'All Blood Requests',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.green,
            unselectedLabelColor: const Color.fromARGB(255, 20, 19, 19),
            indicatorColor: Colors.green,
            controller: _tabController,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Tomorrow'),
              Tab(text: 'Later'),
            ],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            indicatorWeight: 3.0,
          ),
        ),
        body: Column(
          children: [
            // Filter dropdowns for blood type, district, province, and local gov
            _buildFilterDropdowns(),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestListView(todayRequests),
                  _buildRequestListView(tomorrowRequests),
                  _buildRequestListView(laterDaysRequests),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdowns() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildBloodGroupDropdown(),
          const SizedBox(height: 4),
          _buildProvinceDropdown(),
          const SizedBox(height: 4),
          _buildDistrictDropdown(),
          const SizedBox(height: 4),
          _buildLocalGovernmentDropdown(),
        ],
      ),
    );
  }

  // Blood Group Dropdown
  DropdownButtonFormField<String> _buildBloodGroupDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(
        labelText: 'Blood Group',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.bloodtype),
      ),
      value: _selectedBloodGroup,
      items: BloodGroup.bloodGroups.map((String bloodGroup) {
        return DropdownMenuItem<String>(
          value: bloodGroup,
          child: Text(bloodGroup),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedBloodGroup = newValue;
        });
        _fetchAndFilterBloodRequest(); // Refetch blood requests
      },
    );
  }

  // Province Dropdown
  DropdownButtonFormField<String> _buildProvinceDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
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
          _districts = LocationData.districtMap[_selectedProvince] ?? [];
          _selectedDistrict = null;
          _selectedLocalGovernment = null;
          _localGovernments = [];
        });
        _fetchAndFilterBloodRequest();
      },
    );
  }

  // District Dropdown
  DropdownButtonFormField<String> _buildDistrictDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
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
              LocationData.localGovernmentMap[_selectedDistrict] ?? [];
          _selectedLocalGovernment = null;
        });
        _fetchAndFilterBloodRequest();
      },
    );
  }

  // Local Government Dropdown
  DropdownButtonFormField<String> _buildLocalGovernmentDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
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
        _fetchAndFilterBloodRequest();
      },
    );
  }

  // Build a ListView for the requests
  Widget _buildRequestListView(List<RequestModel> requests) {
    if (requests.isEmpty) {
      return const Center(child: Text("No requests found."));
    } else {
      return ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          RequestModel bloodRequest = requests[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(16),
              color: const Color.fromARGB(255, 236, 227, 227),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(8),
              title: Text(bloodRequest.bloodGroup ?? "Unknown blood type",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "Phone number: ${bloodRequest.phoneNumber ?? "No phone number"}",
                  style:
                      const TextStyle(color: Color.fromARGB(255, 114, 111, 111))),

                        onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      BasicDetails(requestModel:bloodRequest),
                                ),
                              );
                            },
            ),
          );
        },
      );
    }
  }
}


class BasicDetails extends StatelessWidget {
  const BasicDetails({super.key, required this.requestModel});

  final RequestModel requestModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 206, 72, 72),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 110, 105, 105).withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 245, 241, 241),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 150, 144, 144).withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient Name: ${requestModel.patientName ?? "-"}'),
              const SizedBox(height: 5),
              Text('Patient Gender: ${requestModel.gender ?? "-"}'),
              const SizedBox(height: 5),
              Text('Blood Group: ${requestModel.bloodGroup ?? "-"}'),
              const SizedBox(height: 5),
              Text(
                  'Contact Person Name: ${requestModel.contactPersonName ?? "-"}'),
              const SizedBox(height: 5),
              Text('Phone: ${requestModel.phoneNumber ?? "-"}'),
              const SizedBox(height: 5),
              Text('Hospital Name: ${requestModel.hospitalName ?? "-"}'),
              const SizedBox(height: 5),
              Text('Required Pint: ${requestModel.requiredPint ?? "-"}'),
              const SizedBox(height: 5),
              Text('Case Detail: ${requestModel.caseDetail ?? "-"}'),
              const SizedBox(height: 5),
              Text('Required Date: ${requestModel.requiredDate ?? "-"}'),
              const SizedBox(height: 5),
              Text('Required Time: ${requestModel.requiredTime ?? "-"}'),
              const SizedBox(height: 5),
              Text('Province: ${requestModel.province ?? "-"}'),
              const SizedBox(height: 5),
              Text('District: ${requestModel.district ?? "-"}'),
              const SizedBox(height: 5),
              Text('Local Government: ${requestModel.localGovernment ?? "-"}'),
              Text('request id: ${requestModel.requestId ?? "-"}'),
            ],
          ),
        ),
      ),
    );
  }
}
