import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'kids_page1.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? currentUser;
  String name = "";
  bool isLoading = true;

  final List<Widget> _pages = [
    HomePage(),
    NotificationsPage(),
    KidsPage(),
    ProfilePage(),
  ];

  Future<String?> fetchStoredSchoolId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('schoolId');
  }

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      _getUserData();
    }
  }

  Future<void> _getUserData() async {
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      setState(() {
        isLoading = false;
      });
      return;
    }
    try {
      String userId = currentUser!.uid;
      DocumentSnapshot userDoc = await _firestore
          .collection('Schools')
          .doc(schoolId)
          .collection('Parents')
          .doc(userId)
          .get();
      setState(() {
        name = userDoc['name'] ?? 'User';
        isLoading = false;
      });
    } catch (e) {
      print("Error getting user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _navigateBasedOnKidsRegistration(DateTime selectedDay) async {
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(schoolId)
        .collection('Parents')
        .doc(user!.uid)
        .collection('Kids')
        .get();

    if (snapshot.docs.isEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => KidsManagementPage1(selectedDate: selectedDay),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => KidsManagementPage2(selectedDate: selectedDay),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset(
                    'assets/images/KiddieWheels Logo.png',
                    width: 250,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 30),
               Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Welcome, $name!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2025, 12, 31),
                    focusedDay: DateTime.now(),
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    onDaySelected: (selectedDay, focusedDay) {
                      _navigateBasedOnKidsRegistration(selectedDay);
                    },
                    calendarStyle: CalendarStyle(
                      cellPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      tablePadding: const EdgeInsets.symmetric(vertical: 10.0),
                      outsideDaysVisible: false,
                      weekendTextStyle: const TextStyle(color: Colors.red),
                      holidayTextStyle: const TextStyle(color: Colors.green),
                      selectedDecoration: const BoxDecoration(
                        color: Color.fromARGB(255, 0, 84, 76),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: const BoxDecoration(
                        color: Color.fromARGB(255, 0, 128, 128),
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: const TextStyle(color: Colors.white),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleTextStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      titleCentered: true,
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: Color.fromARGB(255, 0, 84, 76),
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: Color.fromARGB(255, 0, 84, 76),
                      ),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 3,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => _pages[index]),
            );
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_outlined),
              label: 'Notifications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_add_outlined), label: 'My Kids'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), label: 'Profile'),
        ],
        selectedItemColor: const Color.fromARGB(255, 0, 84, 76),
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Prevent shifting
      ),
    );
  }
}


/////DEFAULT (BEFORE REGISTER)/////////////
class KidsManagementPage1 extends StatefulWidget {
  final DateTime selectedDate; // Pass the selected date

  KidsManagementPage1({required this.selectedDate});

  @override
  _KidsManagementPage1State createState() => _KidsManagementPage1State();
  }

class _KidsManagementPage1State extends State<KidsManagementPage1>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _currentDate;   ///tambah 1
  int _currentIndex=0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentDate = widget.selectedDate; ///tambah 2
  }

    void _goToPreviousDate() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }   ////tambah 3

    void _goToNextDate() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }     ////tambah 4

    String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,

            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly distribute elements
                  children: [
                    GestureDetector(
                      onTap: _goToPreviousDate,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 0, 128, 128),
                          borderRadius: BorderRadius.circular(20), // Oval background
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1), // Adjust padding for oval shape
                        child: const Icon(Icons.arrow_left, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 20), // Adjust this value for left spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDate(_currentDate),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.calendar_today, color: Colors.black, size: 18),
                      ],
                    ),
                    const SizedBox(width: 65), // Adjust this value for right spacing
                    GestureDetector(
                      onTap: _goToNextDate,
                      child: Container(
                        decoration: BoxDecoration(
                          color:  Color.fromARGB(255, 0, 128, 128),
                          borderRadius: BorderRadius.circular(20), // Oval background
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1), // Adjust padding for oval shape
                        child: const Icon(Icons.arrow_right, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Space between the date row and tabs
              ],
            ),


        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Drop-Off'),
            Tab(text: 'Pick-Up'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNoKidsAvailableView(_currentDate),  // Drop-Off Tab Content
          _buildNoKidsAvailableView(_currentDate),  // Pick Up Tab Content
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        //backgroundColor: Colors.deepPurple,
        elevation: 3,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Handle the BottomNavigationBar item selection here
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.group_add_outlined), label: 'My Kids'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Profile'),
        ],
        selectedItemColor: const Color.fromARGB(255, 0, 84, 76),
        //showSelectedLabels: false,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // View for showing no kids available
  Widget _buildNoKidsAvailableView(DateTime date) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Kids Available',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ),
          ),
          SizedBox(height: 8),
          Text(
            'Please register your kids first.',
            style: TextStyle(fontSize: 16, color: Colors.grey, ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to the kids registration page
              Navigator.push(context, MaterialPageRoute(builder: (context) => KidsPage()));
            },
            child: Text('Go to kids page', style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
    );
  }

  // Helper function to get month name from integer
  String _getMonthName(int month) {
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class KidsManagementPage2 extends StatefulWidget {
  final DateTime selectedDate; // Pass the selected date

  KidsManagementPage2({required this.selectedDate});

  @override
  _KidsManagementPage2State createState() => _KidsManagementPage2State();
}

 class _KidsManagementPage2State extends State<KidsManagementPage2>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  late DateTime _currentDate;
  int _currentIndex = 0;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  List<Map<String, dynamic>> kidsList = [];
  Map<String, Map<String, dynamic>> attendanceData = {};

  // List of pages to navigate to
  final List<Widget> _pages = [
    HomePage(),
    NotificationsPage(),
    KidsPage(),
    ProfilePage(),
  ];

   Future<String?> fetchStoredSchoolId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('schoolId');
}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _user = _auth.currentUser;
    _currentDate = widget.selectedDate;
    fetchKidsData();

    //fetchAttendanceData(); 
    //fetchPickUpData();    ////tryyyyy
  }

    void _goToPreviousDate() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDate() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }

String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
}

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

Future<void> fetchKidsData() async {
   String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }

  if (_user != null) {
    try {
      // Fetch all kids for the current user
      final kidsSnapshot = await _firestore
          .collection('Schools')
          .doc(schoolId)
          .collection('Parents')
          .doc(_user!.uid)
          .collection('Kids')
          .get();

      List<Map<String, dynamic>> tempKidsList = []; // Temporary list to store data

      for (var kidDoc in kidsSnapshot.docs) {
        final kidData = kidDoc.data();

        // Fetch attendance and pick-up records in parallel
        final attendanceSnapshotFuture = _firestore
            .collection('Schools')
            .doc(schoolId)
            .collection('Parents')
            .doc(_user!.uid)
            .collection('Kids')
            .doc(kidDoc.id)
            .collection('attendanceRecords')
            .get();

        final pickUpSnapshotFuture = _firestore
            .collection('Schools')
            .doc(schoolId)
            .collection('Parents')
            .doc(_user!.uid)
            .collection('Kids')
            .doc(kidDoc.id)
            .collection('pickUpRecords')
            .get();

        // Wait for both futures to complete
        final [attendanceSnapshot, pickUpSnapshot] = await Future.wait([
          attendanceSnapshotFuture,
          pickUpSnapshotFuture,
        ]);

        // Convert snapshots to maps
        final attendanceRecords = Map.fromEntries(attendanceSnapshot.docs.map((doc) {
          return MapEntry(doc.id, doc.data());
        }));

        final pickUpRecords = Map.fromEntries(pickUpSnapshot.docs.map((doc) {
          return MapEntry(doc.id, doc.data());
        }));

        // Fetch the timeSlot for the selected date
        final timeSlotForDate = pickUpRecords[widget.selectedDate.toIso8601String()]?['timeSlot'];

        // Add timeSlot to kid data if available
        kidData['selectedTimeSlot'] = timeSlotForDate;

        // Combine all the data and update the tempKidsList
        tempKidsList.add({
          'id': kidDoc.id,
          ...kidData,
          'attendanceRecords': attendanceRecords,
          'pickUpRecords': pickUpRecords,
        });

        // Save/update the kid data in the global "AllKids" collection
        await _firestore
            .collection('Schools')
            .doc(schoolId)
            .collection('AllKids') // Reference to the AllKids collection
            .doc(kidDoc.id) // Document ID is the kid's ID
            .set({
              ...kidData,
            }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data
      }

      // Now update the main kidsList and trigger UI update
      setState(() {
        kidsList = tempKidsList; // Assign the combined data to kidsList
      });
    } catch (error) {
      // Handle errors during the fetch operation
      print('Error fetching kids data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load kids data')),
      );
    }
  } else {
    print('User is null');
  }
}

          
  bool _isPresent = true; // Attendance flag
  String? reason = ''; // Reason for absence
  bool isDefault = false; // Default flag
  String? selectedTimeSlot; // Track selected pick-up slot
  Map<String, String> selectedTimeSlots = {}; 

Future<void> saveAttendanceData(String kidId, String attendance, String date, {String? reason}) async {
  if (_user != null) {

    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }

    try {
      final parentDoc = _firestore
          .collection('Schools')
          .doc(schoolId)
          .collection('Parents')
          .doc(_user!.uid)
          .collection('Kids')
          .doc(kidId);

      await parentDoc.collection('attendanceRecords').doc(date).set({
        'attendance': attendance,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
        'date': date,
      }, SetOptions(merge: true));

      // Write to the global AllKids collection
      final kidSnapshot = await parentDoc.get();
      if (kidSnapshot.exists) {
        final kidData = kidSnapshot.data()!;
        await _firestore
            .collection('Schools')
            .doc(schoolId)
            .collection('AllKids')
            .doc(kidId)
            .collection('attendanceRecords')
            .doc(date)
            .set({
          'attendance': attendance,
          if (reason != null && reason.isNotEmpty) 'reason': reason,
          'date': date,
          'name': kidData['name'],
          'grade': kidData['grade'],
          'class': kidData['class'],
          'parentId': _user!.uid,
        }, SetOptions(merge: true));
      }

      // Fetch the latest kids data after saving the attendance
      await fetchKidsData();
    } catch (error) {
      print('Error saving attendance: $error');
    }
  }
}

Future<void> savePickUpData(String timeSlot, String date) async {
  if (_user != null) {
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }
    try {
      // Filter present kids
      final presentKids = kidsList.where((kid) {
        final attendanceRecords = kid['attendanceRecords'] ?? {};
        final attendanceData = attendanceRecords[date];
        return attendanceData != null && attendanceData['attendance'] == 'Present';
      }).toList();

      for (var kid in presentKids) {
        // Save to parent's collection
        final parentKidDoc = _firestore
            .collection('Schools')
            .doc(schoolId)
            .collection('Parents')
            .doc(_user!.uid)
            .collection('Kids')
            .doc(kid['id']);
          
            await parentKidDoc.collection('pickUpRecords').doc(date).set({'timeSlot': timeSlot}, SetOptions(merge: true));
        

        // Mirror data to global AllKids collection
        final kidSnapshot = await parentKidDoc.get(); // Fetch parent kid data
        if (kidSnapshot.exists) {
          final kidData = kidSnapshot.data()!; // Fetch kid data from parent's collection
          await _firestore
              .collection('Schools')
              .doc(schoolId)
              .collection('AllKids')
              .doc(kid['id'])
              .collection('pickUpRecords')
              .doc(date)
              .set({
            'timeSlot': timeSlot,
            'date': date,
            'name': kidData['name'], // Include kid's name
            'grade': kidData['grade'],
            'class': kidData['class'], // Include kid's class
            'parentId': _user!.uid, // Reference to parent
            'status': 'Waiting'
          }, SetOptions(merge: true));
        }
      }

      // Update local state
      setState(() {
        selectedTimeSlot = timeSlot;
      });

      // Fetch updated data
      await fetchKidsData();
    } catch (error) {
      print('Error saving pick-up data: $error');
      // Optionally show error feedback to the user
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,

              title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Evenly distribute elements
                  children: [
                    GestureDetector(
                      onTap: _goToPreviousDate,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 0, 128, 128),
                          borderRadius: BorderRadius.circular(20), // Oval background
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1), // Adjust padding for oval shape
                        child: const Icon(Icons.arrow_left, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 0), // Adjust this value for left spacing
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDate(_currentDate),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 0), // Adjust this value for right spacing
                    GestureDetector(
                      onTap: _goToNextDate,
                      child: Container(
                        decoration: BoxDecoration(
                          color:  Color.fromARGB(255, 0, 128, 128),
                          borderRadius: BorderRadius.circular(20), // Oval background
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 1), // Adjust padding for oval shape
                        child: const Icon(Icons.arrow_right, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Space between the date row and tabs
              ],
            ),

        backgroundColor: Colors.transparent,
        bottom: TabBar(
            controller: _tabController,
            indicatorColor: Color.fromARGB(255, 0, 128, 128), // Custom indicator color          
            indicatorSize: TabBarIndicatorSize.label,
            //indicator: BoxDecoration(color: Color.fromARGB(7, 0, 128, 128)),
            indicatorWeight: 3.0, // Thickness of the indicator
            labelColor: Colors.black, // Color of selected tab's text
            unselectedLabelColor: Colors.grey, // Color of unselected tabs' text
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16, // Font size for selected tab
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              //fontFamily: 'Inter',
              fontSize: 16, // Font size for unselected tab
            ),
            tabs: [
              Tab(text: 'Drop-Off'),
              Tab(text: 'Pick-Up'),
            ],
          ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDropOffView(_currentDate), // Drop-Off Tab Content
          _buildPickUpView(_currentDate),  // Pick-Up Tab Content
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        //backgroundColor: Colors.deepPurple,
        elevation: 3,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => _pages[index]),
            );
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_outlined), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.group_add_outlined), label: 'My Kids'),
          BottomNavigationBarItem(icon: Icon(Icons.person_2_outlined), label: 'Profile'),
        ],
        selectedItemColor: const Color.fromARGB(255, 0, 84, 76),
        //showSelectedLabels: false,
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Build the list view of registered kids

Widget _buildDropOffView(DateTime date) {
  return ListView.builder(
    itemCount: kidsList.length,
    itemBuilder: (context, index) {
      final kid = kidsList[index];
      final kidId = kid['id'];
      final attendanceRecords = kid['attendanceRecords'] ?? {};
      //final attendanceData = attendanceRecords[widget.selectedDate.toIso8601String()];
      final attendanceData = attendanceRecords[_currentDate.toIso8601String()];

      print('attendance Data: $attendanceData');
      print('kid list: $kidsList');

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 40, color: Colors.black),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kid['name'],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          kid['class'],
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                attendanceData != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: attendanceData['attendance'] == 'Present'
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              attendanceData['attendance'] == 'Present' ? 'Present' : 'Absent',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _showAttendanceDialog(context, kidId, kid['name'], kid['class']);
                            },
                            child: Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(Icons.add, color: Colors.black),
                          onPressed: () {
                            _showAttendanceDialog(context, kidId, kid['name'], kid['class']);
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
    },
  );
}


 void _showAttendanceDialog(BuildContext context, String kidId, String kidName, String kidClass) {
    setState(() {
      _isPresent = true; // Default presence
      reason = '';
      isDefault = false;
    });

   showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 2,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(kidName, style: TextStyle(fontSize: 16)),
                Text(kidClass, style: TextStyle(fontSize: 14)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPresenceButton(context, 'Present', true, setState),
                    SizedBox(width: 20),
                    _buildPresenceButton(context, 'Absent', false, setState),
                  ],
                ),
                SizedBox(height: 20),
                TextFormField(
                  enabled: !_isPresent,
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    //labelStyle: TextStyle(fontFamily: 'Inter'),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    reason = value;
                  },
                ),
                SizedBox(height: 10),
                SwitchListTile(
                  title: Text('Set as default?', style: TextStyle(fontSize: 12)),
                  value: isDefault,
                  onChanged: (value) {
                    setState(() {
                      isDefault = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: TextStyle(color: Colors.black),),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save attendance to Firebase
                      await saveAttendanceData(
                        kidId,
                        _isPresent ? 'Present' : 'Absent',
                        widget.selectedDate.toIso8601String(),
                        reason: _isPresent ? null : reason,
                      );

                      await fetchKidsData();

                      // Local UI update
                      setState(() {
                        attendanceData[widget.selectedDate.toIso8601String()] = {
                          'attendance': _isPresent ? 'Present' : 'Absent',
                          if (!_isPresent) 'reason': reason ?? '',
                        };
                      });

                      // Debugging
                      print('Attendance Data Saved: $attendanceData');

                      // Close the dialog
                      Navigator.pop(context);

                      // Optional: show confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Attendance saved successfully!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      //backgroundColor: Colors.white,
                      //shape: CircleBorder(),
                      //side: const BorderSide(color: Color.fromARGB(255, 0, 84, 76), width: 2),
                      backgroundColor: Color.fromARGB(255, 0, 128, 128),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                      //padding: EdgeInsets.all(20),
                    ),
                    child: Text('Confirm', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
   );
 }

  // Helper to build Present/Absent buttons
  Widget _buildPresenceButton(BuildContext context, String text, bool isPresent, void Function(void Function()) setState) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPresent = isPresent;
        });
      },
      child: Column(
        children: [
          Icon(
              isPresent == _isPresent
                  ? Icons.check_circle_outline_sharp
                  : Icons.radio_button_unchecked,
              color: isPresent == _isPresent ? Colors.blue : Colors.grey,
              size: 30),
          Text(text),
        ],
      ),
    );
  }
  

bool isCallButtonDisabled = false; // State variable to track button availabilit

void _showCallingPopup(BuildContext context) {
  final presentKids = kidsList.where((kid) {
    final attendanceRecords = kid['attendanceRecords'] ?? {};
    final attendanceData = attendanceRecords[widget.selectedDate.toIso8601String()];
    return attendanceData != null && attendanceData['attendance'] == 'Present';
  }).toList();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return _AnimatedSpeakerDialog(
        presentKids: presentKids,
        selectedDate: widget.selectedDate,
        updateKidStatus: updateKidStatus,
        onCallComplete: () {
          setState(() {
            isCallButtonDisabled = true;
          });
        },
      );
    },
  );
}




void updateKidStatus(String kidId, String newStatus, String date) async{   //tadi takde async
  if (_user != null) {
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }
  FirebaseFirestore.instance
      .collection('Schools')
      .doc(schoolId)
      .collection('AllKids')
      .doc(kidId) // Update this specific kid's document
      .collection('pickUpRecords')
      .doc(date)
      .update({'status': newStatus});
}
}


Widget _buildPickUpView(DateTime date) {
  final presentKids = kidsList.where((kid) {
    final attendanceRecords = kid['attendanceRecords'] ?? {};
    //final attendanceData = attendanceRecords[widget.selectedDate.toIso8601String()];

    final attendanceData = attendanceRecords[_currentDate.toIso8601String()];
    return attendanceData != null && attendanceData['attendance'] == 'Present';
  }).toList();

  // Find the timeSlot for the selected date, assuming all kids share the same timeSlot
  final timeSlot = presentKids.isNotEmpty ? presentKids[0]['selectedTimeSlot'] : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section: Today's Pick-Up
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Today's Pick-Up",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      if (presentKids.isEmpty)
        Center(
          child: Text(
            "No kids attended today.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
      else
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: presentKids.length,
          itemBuilder: (context, index) {
            final kid = presentKids[index];
            return ListTile(
              leading: CircleAvatar(
              backgroundColor: Colors.grey[300], // Background color of the avatar
              child: Icon(Icons.person, size: 40, color: Colors.black), // Person icon
            ),
              title: Text(kid['name'], style: TextStyle(fontSize: 16)),
              subtitle: Text(kid['class'], style: TextStyle(fontSize: 14, color: Colors.grey)),
            );
            
          },
         // const Divider(thickness: 1, indent: 10.0, endIndent: 10.0,);
        ),

      SizedBox(height: 20),

      // Section: Pick-Up Time Slot
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          "Pick-Up Time Slot",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(height: 40),
      Center(
        child: Column(
          children: [
            //if (selectedTimeSlot != null)
            if (timeSlot != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Time Slot: $timeSlot",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    onPressed: () {
                      _showPickUpSlotDialog();
                    },
                    child: Text("Edit", style: TextStyle(color: Colors.blue)),
                  ),
                ],
              )
            else
              OutlinedButton(
                onPressed: () {
                  _showPickUpSlotDialog();
                },
                 style: OutlinedButton.styleFrom(
                  //backgroundColor: Colors.white,
                  //shape: CircleBorder(),
                  side: const BorderSide(color: Color.fromARGB(255, 0, 84, 76), width: 2),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                  padding: EdgeInsets.all(20),
                ),
                child: Text("Choose Time Slot", style: TextStyle(color:Color.fromARGB(255, 0, 84, 76))),
              ),

            SizedBox(height: 50),
          
            FutureBuilder<Position>(
  future: timeSlot == null
      ? null 
      : Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        ),
  builder: (context, snapshot) {
    bool isCallButtonDisabled = true;
    String statusMessage = "Please select a time slot";

    if (timeSlot != null) {
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasData) {
          final position = snapshot.data!;
          final distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
              3.2515766,// school's latitude
              101.7322521, //school's longitude
          );

          isCallButtonDisabled = distance > 300; // Disable button if distance > 300 meters
          statusMessage = isCallButtonDisabled
              ? "Too far from school"
              : "You are at school";
        } else {
          statusMessage = "Location not available";
        }
      } else {
        statusMessage = "Checking location...";
      }
    }

    return Column(
      children: [
        if (timeSlot != null) ...[
          Text(
            statusMessage,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: isCallButtonDisabled
                ? null // Disable button if too far
                : () {
                    for (final kid in presentKids) {
                      final kidId = kid['id'];
                      updateKidStatus(kidId, 'Calling', widget.selectedDate.toIso8601String());
                    }
                    _showCallingPopup(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCallButtonDisabled
                  ? Colors.grey // Disabled button color
                  : const Color.fromARGB(255, 199, 29, 17),
              shape: CircleBorder(),
              padding: EdgeInsets.all(40),
            ),
            child: Text(
              'Call',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ] else
          Text(
            "Please select a time slot to enable the Call button",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
                  ],
                );
              },
            ),

          ],
        ),
      ),
    ],
  );
}

void _showPickUpSlotDialog() {
  String? tempSelectedSlot = selectedTimeSlot; // Initialize with the current slot

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            elevation: 2,
            title: const Text(
              "Choose Pick-Up Time Slot",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var slot in ["4:00PM - 4:30PM", "4:30PM - 5:00PM", "5:00PM - 5:30PM", "5:30PM - 6:00PM"])
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        tempSelectedSlot = slot;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      decoration: BoxDecoration(
                        color: tempSelectedSlot == slot ? Colors.teal[50] : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: tempSelectedSlot == slot ? Colors.teal : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          slot,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: tempSelectedSlot == slot ? FontWeight.bold : FontWeight.normal,
                            color: tempSelectedSlot == slot ? Colors.teal : Colors.black,
                          ),
                        ),
                        leading: Radio<String>(
                          value: slot,
                          groupValue: tempSelectedSlot,
                          onChanged: (value) {
                            setState(() {
                              tempSelectedSlot = value;
                            });
                          },
                          activeColor: Colors.teal,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Color.fromARGB(255, 0, 84, 76)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (tempSelectedSlot != null) {
                        savePickUpData(tempSelectedSlot!, widget.selectedDate.toIso8601String());
                        setState(() {
                          selectedTimeSlot = tempSelectedSlot;
                        });
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 84, 76),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}



  // Helper function to get month name from integer
  String _getMonthName(int month) {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }
}

class _AnimatedSpeakerDialog extends StatefulWidget {
  final List<dynamic> presentKids;
  final DateTime selectedDate;
  final Function(String kidId, String status, String date) updateKidStatus;
  final VoidCallback onCallComplete;

  const _AnimatedSpeakerDialog({
    Key? key,
    required this.presentKids,
    required this.selectedDate,
    required this.updateKidStatus,
    required this.onCallComplete,
  }) : super(key: key);

  @override
  __AnimatedSpeakerDialogState createState() => __AnimatedSpeakerDialogState();
}

class __AnimatedSpeakerDialogState extends State<_AnimatedSpeakerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 30),

          // Animated Speaker Image
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Image.asset(
              'assets/images/speaker_3d.png',
              width: 200,
              height: 200,
            ),
          ),
          const SizedBox(height: 16),

          // Title Text
          const Text(
            'Calling for your kids...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 30),

          // Dismiss Button
          ElevatedButton(
            onPressed: () {
              for (final kid in widget.presentKids) {
                final kidId = kid['id'];
                widget.updateKidStatus(
                  kidId,
                  'Dismissed',
                  widget.selectedDate.toIso8601String(),
                );
              }
              widget.onCallComplete();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 84, 76),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Dismiss',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Cancel Button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
