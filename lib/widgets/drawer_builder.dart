import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pcte_event_management/Api_Calls/api_calls.dart';
import 'package:pcte_event_management/LocalStorage/Secure_Store.dart';
import 'package:pcte_event_management/Providers/login_provider.dart';
import 'package:pcte_event_management/ui/Event.dart';
import 'package:pcte_event_management/ui/UserUpdateScreen.dart';
import 'package:pcte_event_management/ui/get_users.dart';
import 'package:pcte_event_management/ui/getallclasses.dart';
import 'package:pcte_event_management/ui/login.dart';
import 'package:pcte_event_management/ui/user_signup.dart';
import 'package:provider/provider.dart';

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
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text("Settings"),
                      onTap: () => Navigator.pop(context),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text("About"),
                      onTap: () => Navigator.pop(context),
                    ),
                    if(userType == 'Admin' || userType == 'Convenor' || userType == 'Teacher')
                      ListTile(
                      leading: const Icon(Icons.exit_to_app),
                      title: const Text("Logout"),
                      onTap: () async {
                        userProvider.onLogOut();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("User Logged Out")));
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
