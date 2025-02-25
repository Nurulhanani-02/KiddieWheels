import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _schoolCodeController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _contactNumberController.dispose();
    _plateNumberController.dispose();
    _schoolCodeController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
  print('Signup method called'); // Add this line
  if (_formKey.currentState!.validate()) {
    print('Form validated'); // Add this line
    try {
      // Validate school code
      final schoolId = await validateSchoolCode(_schoolCodeController.text.trim());
      print('Validated School ID: $schoolId'); // Debugging log

      if (schoolId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid school code.")),
        );
        return;
      }

      // Create parent account
  final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _emailController.text.trim(),
    password: _passwordController.text.trim(),
  );

  final parentId = userCredential.user!.uid;
  print('User created successfully. UID: $parentId');

  // Check if the user is authenticated
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('Error: User is not authenticated after signup.');
    return;
  } else {
    print('Authenticated user after signup: ${currentUser.uid}');
  }

      // Add parent data under the school's Users subcollection
      await FirebaseFirestore.instance
          .collection('Schools')
          .doc(schoolId)
          .collection('Parents')
          .doc(parentId)
          .set({
        'name': _nameController.text.trim(),
        'contact': _contactNumberController.text.trim(),
        'email': _emailController.text.trim(),
        'plateNumber': _plateNumberController.text.trim(),
        'schoolId': schoolId,
        'createdAt': DateTime.now(),
      });

      print('Parent data added to Firestore.');

      // Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully.")),
      );

    } catch (e) {
      print('Error during sign-up: $e'); // Log error to console
      String errorMessage = "Sign-up failed. Please try again.";
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          errorMessage = "This email is already in use.";
        } else if (e.code == 'weak-password') {
          errorMessage = "The password is too weak.";
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }
}

  Future<String?> validateSchoolCode(String code) async {
  print('validateSchoolCode called with code: $code'); // Debug log

  print('Attempting to read Schools collection');


final querySnapshot = await FirebaseFirestore.instance
    .collection('Schools')
    .where('schoolCode', isEqualTo: code)
    .get();

  print('Query successful: ${querySnapshot.docs.length} documents found');


  if (querySnapshot.docs.isEmpty) {
    return null; // Invalid code
  }

  return querySnapshot.docs.first.id; // Return the schoolId if valid
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/KiddieWheels Logo.png', width: 200, height: 90),
                const SizedBox(height: 10),
                SizedBox(height: 20),
                Text(
                  'Create Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Enter your name',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 10),

                TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
               validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null; // Explicitly return null when the input is valid
                  },
              ),
              const SizedBox(height: 10),

                 TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                obscureText: true,
                validator: (value) =>
                      value == null || value.isEmpty || value.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
              ),
                SizedBox(height: 10),

                TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(
                  labelText: 'Enter your contact number',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                
                validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your contact number' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                controller: _plateNumberController,
                decoration: InputDecoration(
                  labelText: 'Enter your plate number',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your plate number' : null,
              ),
                SizedBox(height: 10),

                 TextFormField(
                controller: _schoolCodeController,
                decoration: InputDecoration(
                  labelText: 'Enter the school code',
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter the school code' : null,
              ),
                SizedBox(height: 20),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _signup,
                  child: Text(
                    'Sign Up',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: const Color.fromARGB(255, 0, 128, 128),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 10),
                  Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your LoginPage widget
                            );
                          },
                          child: const Text(
                            'Go to Login Page',
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 76, 84),
                              fontSize: 14,     
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter your $label...',
            hintStyle: const TextStyle(color: Color.fromARGB(255, 186, 184, 184)),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          style: const TextStyle(fontSize: 14),
          validator: validator,
        ),
      ],
    );
  }
}

