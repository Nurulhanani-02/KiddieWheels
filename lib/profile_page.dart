import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'notifications_page.dart';
import 'kids_page1.dart';
import 'login.dart';

///////////////////////////////////////////////////

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late User? currentUser;
  late String name = "";
  late String contact = "";
  late String email = "";
  late String plateNumber = "";

  bool isLoading = true;

  int _currentIndex = 3;
 // bool isKidRegistered = false;

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
    currentUser = _auth.currentUser;
    if (currentUser != null) {
      _getUserData();
    }
  }

  Future<void> _getUserData() async {
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }
    try {
      String userId = currentUser!.uid;
      
      DocumentSnapshot userDoc = await _firestore.collection('Schools').doc(schoolId).collection('Parents').doc(userId).get();
      setState(() {
        name = userDoc['name'];
        contact = userDoc['contact'];
        email = userDoc['email'];
        plateNumber = userDoc['plateNumber'];
        isLoading = false;
      });
    } catch (e) {
      print("Error getting user data: $e");
    }
  }

  // Function to show confirmation dialog
void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text('Confirm Logout', style: TextStyle(fontSize: 16),),
        content: Text('Are you sure you want to log out?', style: TextStyle(fontSize: 14)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Dismiss the dialog
              Navigator.of(context).pop();
            },
            child: Text('Cancel', style: TextStyle(fontSize: 14, color: Colors.black),),
          ),
          TextButton(
            onPressed: () async {
              // Sign out the user
              try {
                await FirebaseAuth.instance.signOut();
                // Navigate to login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your login screen
                );
              } catch (e) {
                print("Error logging out: $e");
              }
            },
            child: Text('Logout', style: TextStyle(color: Colors.red, fontSize: 14),),
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
        'My Profile',
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent, // Transparent for custom background
      elevation: 0, // Remove default AppBar shadow
    ),
    
  ),
  
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card
            Card(
             // color: const Color.fromARGB(211, 145, 201, 196),
              color: Colors.white,
              elevation: 3, // Slight elevation for the profile card
              shadowColor: Colors.grey,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
              
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Picture
                    CircleAvatar(
                      //radius: 32,
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      child: Icon(Icons.person, size: 80, color: Color.fromARGB(255, 0, 128, 128)),
                      //backgroundImage: AssetImage('assets/profile_picture.png'), // Add your profile picture here

                    ),
                    const SizedBox(width: 16),
                    // Profile Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                         SizedBox(height: 8),
                          Text(contact, style: TextStyle(fontSize: 16, color: Colors.black)),
                          SizedBox(height: 8),
                          Text(email, style: TextStyle(fontSize: 16, color: Colors.black)),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Edit Profile Button
            SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Edit Profile
                    Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => EditProfilePage(
                                          name: name,
                                          phone: contact,
                                          email: email,
                                          plateNumber: plateNumber,
                                        )),
                              );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: const Color.fromARGB(255, 0, 128, 128), // Button color
                ),
                child: const Text(
                  'Edit profile',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Spacer(),

            // Logout Button
            OutlinedButton(
              onPressed: () {
                // Show the confirmation dialog
                _showLogoutConfirmationDialog(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18.0),
                side: const BorderSide(color: Color.fromARGB(255, 200, 29, 17), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 200, 29, 17),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
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


///////////////UNTUK EDIT PROFILE//////////////

class EditProfilePage extends StatefulWidget {
  final String name;
  final String phone;
  final String email;
  final String plateNumber;
  //final String plateNumber;

  EditProfilePage({
    required this.name,
    required this.phone,
    required this.email,
    required this.plateNumber,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _plateNumberController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isSaving = false;

  int _currentIndex = 3;
  bool isKidRegistered = false;

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
    _nameController = TextEditingController(text: widget.name);
    _phoneController = TextEditingController(text: widget.phone);
    _emailController = TextEditingController(text: widget.email);
    _plateNumberController = TextEditingController(text: widget.plateNumber);
  }

  Future<void> _saveProfile() async {
    String? schoolId = await fetchStoredSchoolId();
    if (schoolId == null) {
      print('School ID not found in local storage.');
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() {
        isSaving = true;
      });
      try {
        User? user = _auth.currentUser;
        String userId = user!.uid;

        await _firestore.collection('Schools').doc(schoolId).collection('Parents').doc(userId).update({
          'name': _nameController.text,
          'contact': _phoneController.text,
          'email': _emailController.text,
          'plateNumber': _plateNumberController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")),
        );
        Navigator.pop(context); // Return to the Profile Page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update profile: $e")),
        );
      } finally {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        'Edit Profile',
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent, // Transparent for custom background
      elevation: 0, // Remove default AppBar shadow
    ),
    
  ),
  
),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Image Section (Optional)
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(169, 202, 202, 202),
                      child: Icon(Icons.person, size: 80, color: Color.fromARGB(255, 0, 128, 128)),
                      //backgroundImage: AssetImage('assets/profile_picture.png'), // Placeholder image
                    ),
                    TextButton(
                      onPressed: () {
                        // Logic to change profile image (optional)
                      },
                      child: Text('Edit profile image', style: TextStyle(color: Colors.blue),),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.black)
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone no.',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.black)
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.black)
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),

              // Plate Number Field
              TextFormField(
                controller: _plateNumberController,
                decoration: InputDecoration(
                  labelText: 'Plate number',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Plate number cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 35),

              // Save and Cancel Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    //style: ButtonStyle(backgroundColor: Color.fromARGB(255, 0, 84, 76)),
                    onPressed: isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 0, 128, 128)),
                    child: isSaving
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 0, 128, 128)),
                          )
                        : Text('Save changes', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel', style: TextStyle(color: Color.fromARGB(255, 0, 84, 76)),),
                  ),
                ],
              ),
            ],
          ),
        ),
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


