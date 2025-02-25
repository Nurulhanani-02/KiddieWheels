import 'package:flutter/material.dart';
import 'home_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/////////////////DEFAULT PAGE (NO KIDS REGISTERED YET)/////////////////
class KidsPage extends StatefulWidget {
  @override
  _KidsPageState createState() => _KidsPageState();
}

class _KidsPageState extends State<KidsPage> {
  int _currentIndex = 2;
  bool isKidRegistered = false;
  bool hasNavigated = false;

  final List<Widget> _pages = [
    HomePage(),
    NotificationsPage(),
    Placeholder(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkIfKidsAreRegistered();
  }

  Future<String?> fetchStoredSchoolId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('schoolId');
}

Future<void> _checkIfKidsAreRegistered() async {
  try {
    // Fetch the stored school ID from local storage
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String parentId = user.uid;

      // Verify if the parent exists under the school
      DocumentSnapshot parentDoc = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Parents')
          .doc(parentId)
          .get();

      if (!parentDoc.exists) {
        print('Parent document does not exist under school $schoolId.');
        return;
      }

      // Fetch kids registered under this parent within the school
      QuerySnapshot kidsSnapshot = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Parents')
          .doc(parentId)
          .collection('Kids')
          .get();

      setState(() {
        isKidRegistered = kidsSnapshot.docs.isNotEmpty;
      });

      //print('Kid is not registered yet');

      if (isKidRegistered && !hasNavigated) {
        hasNavigated = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToKidsListPage();
        });
      }
    } else {
      print('No authenticated user found.');
    }
  } catch (e) {
    print("Error checking kids registration: $e");
  }
}

  void _navigateToKidsListPage() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => KidsListPage()),
      );
    }
  }

  Widget _defaultKidsView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.family_restroom, size: 90, color: Colors.black),
        SizedBox(height: 16),
        Text(
          "Oh no! Seems like you haven't\n registered your kids yet...",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => KidsDetails1Page()),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 16),
            backgroundColor: Color.fromARGB(255, 0, 84, 76),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text('Add kids', style: TextStyle(fontSize: 14, color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(child: Text("No user is logged in"));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(58.0), // Standard AppBar height
          child: Container(
            decoration: BoxDecoration(
            // color: Colors.white, // AppBar background color
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300, // Divider line color
                  width: 1.5, // Thickness of the divider
                ),
              ),
            ),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'My Kids',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Transparent for custom background
              elevation: 0, // Remove default AppBar shadow
            ),
          ),
        ),
      body: Center(
        child: isKidRegistered ? CircularProgressIndicator() : _defaultKidsView(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        //backgroundColor: Colors.white,
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
}


///////////////////////////////////////////////////
///////////////UNTUK FIRST TIME KEY IN DETAILS////////////////////////

class KidsDetails1Page extends StatefulWidget {
  @override
  _KidsDetails1PageState createState() => _KidsDetails1PageState();
}

class _KidsDetails1PageState extends State<KidsDetails1Page> {
  int _currentIndex = 2;

List<Map<String, dynamic>> kidsDetails = [
  {
    'name': null,           // Represents no name entered yet
    'grade': null,          // Represents no grade selected yet
    'class': null,          // Represents no class selected yet
  }
];


  final List<Widget> _pages = [
    HomePage(),
    NotificationsPage(),
    KidsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    loadKidsDetails(); // Load kids' details on initialization
  }

bool validateKidsDetails() {
  for (var kid in kidsDetails) {
    if (kid['name'].isEmpty || kid['grade'].isEmpty || kid['class'].isEmpty) {
      return false;
    }
  }
  return true;
}

Future<String?> fetchStoredSchoolId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('schoolId');
}

Future<void> saveKidsDetailsToFirebase() async {
  String? schoolId = await fetchStoredSchoolId();
  if (schoolId == null) {
    print('School ID not found in local storage.');
    return;
  }

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    String parentId = user.uid;

    // Reference collections using the fetched schoolId
      CollectionReference parentKidsCollection = FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Parents')
          .doc(parentId)
          .collection('Kids');

      CollectionReference schoolAllKidsCollection =
          FirebaseFirestore.instance.collection('Schools').doc(schoolId).collection('AllKids');
    
    try {
    
      // Fetch parent's details
      DocumentSnapshot parentDoc = await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Parents')
          .doc(parentId)
          .get();

      if (!parentDoc.exists) {
        throw 'Parent document does not exist.';
      }

      Map<String, dynamic>? parentData = parentDoc.data() as Map<String, dynamic>?;
      if (parentData == null) {
        throw 'Failed to fetch parent data.';
      }

      String parentName = parentData['name'] ?? 'Unknown';
      String plateNumber = parentData['plateNumber'] ?? 'Unknown';
      String contactNumber = parentData['contact'] ?? 'Unknown';

      // Save kids' details
      for (var kid in kidsDetails) {

        if (kid['name'].isEmpty || kid['grade'].isEmpty || kid['class'].isEmpty) {
          throw 'Missing required fields for one or more kids.';
        }

        String kidId = schoolAllKidsCollection.doc().id; // Unique ID for each kid
        Map<String, dynamic> kidData = {
          'name': kid['name'],
          'grade': kid['grade'],
          'class': kid['class'],
          'parentId': parentId,
          'parentName': parentName,
          'plateNumber': plateNumber,
          'contactNumber': contactNumber,
          'schoolId': schoolId,
        };

        // Save to parent's Kids sub-collection
        await parentKidsCollection.doc(kidId).set(kidData);

        // Save to school's AllKids sub-collection
        await schoolAllKidsCollection.doc(kidId).set(kidData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kids\' details saved successfully.')),
      );
    } catch (e) {
      print('Error saving kids details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving kids\' details: $e')),
      );
    }
  }
}


  // Save kids' details and registration status to SharedPreferences
  Future<void> saveKidsDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> kidsDetailsEncoded = kidsDetails.map((kid) => json.encode(kid)).toList();
    await prefs.setStringList('kidsDetails', kidsDetailsEncoded);
    await prefs.setBool('isKidRegistered', true);
  }


  // Load kids' details from SharedPreferences
  Future<void> loadKidsDetails() async {
    //print('problem here? 1');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? kidsDetailsEncoded = prefs.getStringList('kidsDetails');
    //print('problem here? 2');
    
    if (kidsDetailsEncoded != null) {
      setState(() {
        kidsDetails = kidsDetailsEncoded.map((kid) => json.decode(kid) as Map<String, dynamic>).toList();
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: 
      PreferredSize(
          preferredSize: Size.fromHeight(58.0), // Standard AppBar height
          child: Container(
            decoration: BoxDecoration(
            // color: Colors.white, // AppBar background color
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300, // Divider line color
                  width: 1.5, // Thickness of the divider
                ),
              ),
            ),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'My Kids',
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Transparent for custom background
              elevation: 0, // Remove default AppBar shadow
              ),
            ),
      ),
      body: Padding(
        //padding: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.only(top: 16.0, right: 16.0, left:16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10.0),
                color: Colors.red[50],
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.red),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your details are secure and private, used only for their intended purpose and never shared with third parties.',
                        style: TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: kidsDetails.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kid ${index + 1}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          if (kidsDetails.length > 1)
                            IconButton(
                              icon: Icon(Icons.person_remove_alt_1_rounded, size: 20, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  kidsDetails.removeAt(index);
                                });
                              },
                            ),
                        ],
                      ),
                      SizedBox(height: 5),
                      TextField(
                        style: TextStyle(fontSize: 14),
                       decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          ),
                        onChanged: (value) {
                          kidsDetails[index]['name'] = value;
                        },
                      ),
                      SizedBox(height: 5),
                      
                      DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                            labelText: 'Grade',
                            labelStyle: TextStyle(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          ),
                      dropdownColor: Colors.white, // Background color for the dropdown menu
                      borderRadius: BorderRadius.circular(20),
                      icon: const Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 0, 128, 128)),
                          items: ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6'].map((String grade) {
                            return DropdownMenuItem<String>(
                              value: grade,
                              child: Text(grade, style: TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (String? newGrade) {
                            setState(() {
                              kidsDetails[index]['grade'] = newGrade!;
                              // Reset class if grade changes
                              kidsDetails[index]['class'] = '';
                            });
                          },
                          value: kidsDetails[index]['grade'] != '' ? kidsDetails[index]['grade'] : null,
                        ),
                        SizedBox(height: 5),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Class',
                            labelStyle: TextStyle(fontSize: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                          ),
                      dropdownColor: Colors.white, // Background color for the dropdown menu
                      borderRadius: BorderRadius.circular(20),
                      icon: const Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 0, 128, 128)),// Background color for the dropdown menu
                          items: _getClassesForGrade(kidsDetails[index]['grade']).map((String className) {
                            return DropdownMenuItem<String>(
                              value: className,
                              //child: Container(
                               //   padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Padding for dropdown items
                                  
                              child: Text(
                                className,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black, // Text color inside dropdown items
                                ),
                              ),
                             // ),
                            );
                          }).toList(),
                          onChanged: (String? newClass) {
                            setState(() {
                              kidsDetails[index]['class'] = newClass!;
                            });
                          },
                          value: kidsDetails[index]['class'] != '' ? kidsDetails[index]['class'] : null,
                        ),

                      SizedBox(height: 7),
                    ],
                  );
                },
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons to fill width
                children: [
                  // Add Button
                  SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          kidsDetails.add({'name': '', 'grade': '', 'class': ''});
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color.fromARGB(255, 0, 84, 76), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: const Color.fromARGB(255, 0, 84, 76),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add, size: 18),
                          SizedBox(width: 2),
                          Text('Add Kid', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Save Changes Button
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        await saveKidsDetailsToFirebase(); // Save to Firebase
                        await saveKidsDetails(); // Save to SharedPreferences
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => KidsListPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 84, 76),
                        elevation: 5,
                        shadowColor: Colors.teal[200], // Add shadow
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Cancel Button
                  SizedBox(
                    height: 35,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
       // backgroundColor: Colors.white,
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
 
}


List<String> _getClassesForGrade(String? grade) {
  if (grade == null || grade.isEmpty) return [];

  final gradeNumber = grade.split(' ')[1]; // Extract grade number (e.g., "Grade 1" → "1")
  return ['${gradeNumber} Ibnu Sina', '${gradeNumber} Ibnu Khaldun', '${gradeNumber} Ibnu Kathir', '${gradeNumber} Ibnu Majah', '${gradeNumber} Ibnu Rusyd', '${gradeNumber} Ibnu Battutah'];
}


///////UNTUK LISTKAN KIDS DETAILS DAN EDIT////

class KidsListPage extends StatefulWidget {
  @override
  _KidsListPageState createState() => _KidsListPageState();
}

class _KidsListPageState extends State<KidsListPage> {
  int _currentIndex = 2;
  bool _isEditing = false;
  List<Map<String, dynamic>> _kidsDetails = [];

  final List<Widget> _pages = [
    HomePage(),
    NotificationsPage(),
    KidsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    //populateAvailableClassesOnPageLoad(schoolId);
    _fetchKidsDetails();
    
  }

  Future<String?> fetchStoredSchoolId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('schoolId');
}

Future<void> _fetchKidsDetails() async {
  try {
    // Get the current authenticated user
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No authenticated user found.');
      return;
    }

    // Fetch stored schoolId
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }

    // Fetch kids data from Firestore using schoolId and parentId
    QuerySnapshot kidsSnapshot = await FirebaseFirestore.instance
        .collection('Schools')
        .doc(schoolId)
        .collection('Parents')
        .doc(user.uid)
        .collection('Kids')
        .get();

    // Debug log to check fetched kids
    print('Number of kids fetched: ${kidsSnapshot.docs.length}');
    for (var doc in kidsSnapshot.docs) {
      print('Kid data: ${doc.data()}');
    }

    // Update state with fetched kids
    setState(() {
      _kidsDetails = kidsSnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'grade': doc['grade'],
                'class': doc['class'],
              })
          .toList();
    });

    print('Fetched kids details: $_kidsDetails');
    
  } catch (e) {
    if (e is FirebaseException) {
      print('Firebase error: ${e.message}');
    } else {
      print('Error fetching kids details: $e');
    }
  }
}

void _saveChanges() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  // Fetch stored schoolId
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }

  try {
    // Validate all kid details before making any changes
    print('Problem here in save changes? 1');
    for (var kid in _kidsDetails) {
      if (kid['name'].isEmpty || kid['grade'].isEmpty || kid['class'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Please fill out all fields."),
          backgroundColor: Colors.red,
        ));
        return; // Exit if validation fails
      }
    }
    print('problem here in save changes? 2');
    // Start a batch for efficient updates
    final batch = FirebaseFirestore.instance.batch();
    final parentKidsCollection = FirebaseFirestore.instance
        .collection('Schools')
        .doc(schoolId)
        .collection('Parents')
        .doc(user.uid)
        .collection('Kids');
    final schoolAllKidsCollection = FirebaseFirestore.instance.collection('Schools').doc(schoolId).collection('AllKids');


    for (var kid in _kidsDetails) {
      final kidData = {
        'name': kid['name'],
        'grade': kid['grade'],
        'class': kid['class'],
      };

      if (kid['id'] != null) {
        // Update existing kid in both collections
        final userKidDoc = parentKidsCollection.doc(kid['id']);
        final globalKidDoc = schoolAllKidsCollection.doc(kid['id']);

        batch.update(userKidDoc, kidData);
        batch.update(globalKidDoc, {
          ...kidData,
          'parentId': user.uid,
          //'status': 'Waiting', // Uncomment if status is needed
        });
      } else {
        // Add new kid in both collections
        final newDocRef = schoolAllKidsCollection.doc();
        batch.set(parentKidsCollection.doc(newDocRef.id), kidData);
        batch.set(newDocRef, {
          ...kidData,
          'parentId': user.uid,
          //'status': 'Waiting', // Uncomment if status is needed
        });
      }
    }

    // Commit the batch
    await batch.commit();

    // Update UI state
    setState(() {
      _isEditing = false; // Exit editing mode
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Changes saved successfully."),
      backgroundColor: Colors.green,
    ));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error saving changes: $e"),
      backgroundColor: Colors.red,
    ));
  }
}

  Future<void> _deleteKid(int index) async {
  User? user = FirebaseAuth.instance.currentUser;

  // Fetch stored schoolId
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }

  if (user != null) {
    // 1. Delete from Users/{userId}/Kids
    await FirebaseFirestore.instance
        .collection('Schools')
        .doc(schoolId)
        .collection('Parents')
        .doc(user.uid)
        .collection('Kids')
        .doc(_kidsDetails[index]['id'])
        .delete();

    // 2. Delete from global Kids collection
    await FirebaseFirestore.instance
        .collection('Schools')
        .doc(schoolId)
        .collection('AllKids')
        .doc(_kidsDetails[index]['id'])
        .delete();
  }

  setState(() {
      _kidsDetails.removeAt(index); // Remove from local list
    });
}


  void _confirmDelete(int index) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text('Delete Kid', style: TextStyle(fontSize: 16),),
        content: Text('Are you sure you want to delete this record?', style: TextStyle(fontSize: 14),),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(fontSize: 14),),
          ),
          TextButton(
            onPressed: () {
              _deleteKid(index);
              Navigator.of(context).pop();
            },
            child: Text('Delete', style: TextStyle(color: Colors.red, fontSize: 14)),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(      
          preferredSize: Size.fromHeight(58.0), // Standard AppBar height
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300, // Divider line color
                  width: 1.5, // Thickness of the divider
                ),
              ),
            ),
            child: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'My Kids',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent, // Transparent for custom background
              elevation: 0, // Remove default AppBar shadow
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });

                    if (!_isEditing) {
                      // Save changes when editing is done
                      _saveChanges();
                    }
                  },
                  child: Text(
                    _isEditing ? 'Save' : 'Edit',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 18, 134, 237),
                      fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Notice
            Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your details are secure and private, used only for their intended purpose and never shared with third parties.',
                      style: TextStyle(color: Colors.red, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),

      // List of Kids Details
      Expanded(
        child: ListView.builder(
          itemCount: _kidsDetails.length,
          itemBuilder: (context, index) {
            //print('_kidsDetails: $_kidsDetails');
           // print('Available Classes: ${_kidsDetails[index]['availableClasses']}');
            //print('Selected Class: ${_kidsDetails[index]['class']}');

            return Card(
              color: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kids Title (e.g., Kid 1, Kid 2, etc.)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Kid ${index + 1}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        // Delete Button (only visible in editing mode)
                        if (_isEditing && _kidsDetails.length > 1)
                          IconButton(
                            icon: Icon(Icons.person_remove_alt_1_rounded, size: 18, color: Colors.red),
                            onPressed: () {
                              _confirmDelete(index);
                            },
                          ),
                      ],
                    ),
                    SizedBox(height: 5),
                    // Name
                    TextFormField(
                      style: TextStyle(fontSize: 14, color: Colors.black),
                      readOnly: !_isEditing,
                      initialValue: _kidsDetails[index]['name'],
                      onChanged: (value) {
                        setState(() {
                          _kidsDetails[index]['name'] = value;
                        });
                      },
                       decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 128, 128)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 128, 128), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 128, 128), width: 2.0),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 234, 250, 250),
                        //contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      ),
                    ),
                    SizedBox(height: 5),
                    // Grade
                    DropdownButtonFormField<String>(
                      value: _kidsDetails[index]['grade'] != '' ? _kidsDetails[index]['grade'] : null,
                      onChanged: _isEditing
                          ? (String? newValue) {
                              setState(() {
                                _kidsDetails[index]['grade'] = newValue ?? '';
                                _kidsDetails[index]['class'] = ''; // Reset class when grade changes
                              });
                            }
                          : null,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select a grade' : null,
                      decoration: InputDecoration(
                        labelText: 'Grade',
                        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 128, 128)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 128, 128), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 128, 128), width: 2.0),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 234, 250, 250),
                        //contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      ),
                      dropdownColor: Colors.white, // Background color for the dropdown menu
                      borderRadius: BorderRadius.circular(20),
                      icon: const Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 0, 128, 128)),
                      items: ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5', 'Grade 6']
                          .map((String grade) {
                        return DropdownMenuItem<String>(
                          value: grade,
                          child: Text(
                            grade,
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: _kidsDetails[index]['class'] != '' ? _kidsDetails[index]['class'] : null,
                      onChanged: _isEditing
                          ? (String? newValue) {
                              setState(() {
                                _kidsDetails[index]['class'] = newValue ?? '';
                              });
                            }
                          : null,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Please select a class' : null,
                      decoration: InputDecoration(
                        labelText: 'Class',
                        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 128, 128)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 128, 128), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 128, 128), width: 2.0),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(255, 234, 250, 250),
                        //contentPadding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                      ),
                      dropdownColor: Colors.white, // Background color for the dropdown menu
                      borderRadius: BorderRadius.circular(20),
                      icon: const Icon(Icons.arrow_drop_down, color: Color.fromARGB(255, 0, 128, 128)),
                      isExpanded: false,
                      items: _getClassesForGrade(_kidsDetails[index]['grade']).map((String className) {
                        return DropdownMenuItem<String>(
                          value: className,
                            child: Text(
                              className,
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            ),
                         // ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // Add New Kid Button (visible only in edit mode)
      if (_isEditing)
        Center(
            child: SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  _kidsDetails.add({'name': '', 'grade': '', 'class': ''});
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color.fromARGB(255, 0, 84, 76), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: const Color.fromARGB(255, 0, 84, 76),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, size: 18),
                  SizedBox(width: 2),
                  Text('Add Kid', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      SizedBox(height: 5),
    ],
  ),
),

      bottomNavigationBar: BottomNavigationBar(
       // backgroundColor: Colors.white,
       elevation: 3,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Handle the BottomNavigationBar item selection here
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
}

  



















