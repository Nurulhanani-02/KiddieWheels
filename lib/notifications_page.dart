import 'package:flutter/material.dart';
import 'kids_page1.dart';
import 'home_page.dart';
import 'profile_page.dart';

////////////////DEFAULT NOTI PAGE//////
class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
int _currentIndex = 1;
  // List of pages to navigate to
  final List<Widget> _pages = [
    HomePage(), // Calendar on Home Page
    NotificationsPage(),
    KidsPage(),
    ProfilePage(),
  ];

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'You have successfully pick-up your kids from school!',
      'time': '10m ago',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
      'category': 'Today'
    },
    {
      'title': 'New update! You changed your phone number.',
      'time': '11:12 a.m.',
      'icon': Icons.update,
      'iconColor': Colors.pink,
      'category': 'Today'
    },
    {
      'title': 'You have successfully drop-off your kids at school!',
      'time': '7:17 a.m.',
      'icon': Icons.school,
      'iconColor': Colors.blue,
      'category': 'Today'
    },
    {
      'title': 'You have successfully pick-up your kids from school!',
      'time': '31 May',
      'icon': Icons.check_circle,
      'iconColor': Colors.green,
      'category': 'Recent'
    },
    {
      'title': 'You have successfully drop-off your kids at school!',
      'time': '31 May',
      'icon': Icons.school,
      'iconColor': Colors.blue,
      'category': 'Recent'
    },
  ];

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
        'Notifications',
        style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent, // Transparent for custom background
      elevation: 0, // Remove default AppBar shadow
    ),
    
  ),
  
),
      body: ListView(
        children: [
          _buildCategorySection('Today'),
          _buildNotificationsByCategory('Today'),
          _buildCategorySection('Recent'),
          _buildNotificationsByCategory('Recent'),
        ],
      ),
       bottomNavigationBar: BottomNavigationBar(
       // backgroundColor: Colors.red,
        elevation: 3,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;  // Update the selected index
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

  Widget _buildCategorySection(String category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        category,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationsByCategory(String category) {
  final categoryNotifications = notifications
      .where((notification) => notification['category'] == category)
      .toList();

  if (categoryNotifications.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'No notifications in $category.',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  return Column(
    children: categoryNotifications.map((notification) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: notification['iconColor'],
              child: Icon(
                notification['icon'],
                color: Colors.white,
              ),
            ),
            title: Text(
              notification['title'],
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            ),
            subtitle: Text(notification['time'], style: TextStyle(fontSize: 12),),
          ),
        ),
      );
    }).toList(),
  );
}
}

  




