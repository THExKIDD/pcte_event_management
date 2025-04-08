import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Providers/login_provider.dart';
import 'package:pcte_event_management/ui/Event.dart';
import 'package:pcte_event_management/ui/UserUpdateScreen.dart';
import 'package:pcte_event_management/ui/bottomNavBar.dart';
import 'package:pcte_event_management/ui/classLogin.dart';
import 'package:pcte_event_management/ui/get_all_registrations_screen.dart';
import 'package:pcte_event_management/ui/get_users.dart';
import 'package:pcte_event_management/ui/getallclasses.dart';
import 'package:pcte_event_management/ui/home.dart';
import 'package:pcte_event_management/ui/login.dart';
import 'package:pcte_event_management/ui/user_signup.dart';
import 'package:provider/provider.dart';

import '../ui/class_events.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final SecureStorage secureStorage = SecureStorage();


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<LoginProvider>(
      builder: (context,userProvider,child)
      {
        return FutureBuilder(
            future: secureStorage.getData('user_type'),
            builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
              String? userType = snapshot.data;
              log(userType.toString());
              return Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(color: Color(0xFF9E2A2F)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Navigation Menu",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          SizedBox(height: size.height * .06,),
                          Text(
                            userType ?? "Student",
                            style: TextStyle(
                                fontSize: 32,
                                color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),


                    if(userType == "Admin")
                      ListTile(
                        leading: const Icon(Icons.people),
                        title: const Text("Get Faculty"),
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => GetAllUsers()));

                        },
                      ),
                    if(userType == "Admin")
                      ListTile(
                        leading: const Icon(Icons.person_add),
                        title: const Text("Add Faculty"),
                        onTap: () {
                          if (mounted) Navigator.pop(context);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => SignUpScreen()));
                        },
                      ),

                    if(userType == "Admin")
                      ListTile(
                        leading: const Icon(Icons.app_registration_sharp),
                        title: const Text("Get All Registrations"),
                        onTap: () {
                          if (mounted) Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => GetAllRegistrationScreen()));
                        },
                      ),



                    if(userType == "Admin" || userType == "Convenor")
                      ListTile(
                        leading: const Icon(Icons.library_add),
                        title: const Text("Create an Event"),
                        onTap: () {
                          if (mounted) Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => EventScreen()));
                        },
                      ),

                    if(userType == "Admin" || userType == "Convenor")
                      ListTile(
                        leading: const Icon(Icons.library_add),
                        title: const Text("Get class"),
                        onTap: () {
                          if (mounted) Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ClassScreen()));
                        },
                      ),


                    if(userType == null)
                      ListTile(
                        leading: const Icon(Icons.login),
                        title: const Text("Login as Faculty"),
                        onTap: () {
                          if (mounted) Navigator.pop(context);
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => Login()));
                        },
                      ),


                    if(userType == null)
                      ListTile(
                        leading: const Icon(Icons.class_outlined),
                        title: const Text("Login as Class"),
                        onTap: () {
                          if (mounted) Navigator.pop(context);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ClassLogin()));
                        },
                      ),

                    if( userType == 'Class')
                      ListTile(
                        leading: const Icon(Icons.event_available_sharp),
                        title: const Text("All Events"),
                        onTap: () async {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
                        },
                      ),

                    if(userType == 'Admin' || userType == 'Convenor' || userType == 'Class')
                      ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text("Logout"),
                      onTap: () async {
                        userProvider.onLogOut();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("User Logged Out")));
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => BottomNavBar()));
                      },
                    ),
                  ],
                ),
              );
            }
        );
      },
    );
  }
}
