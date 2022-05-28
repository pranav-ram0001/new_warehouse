import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:new_warehouse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key, key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

String? userName = FirebaseAuth.instance.currentUser?.email;

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final logOutButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.teal,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          userName = "";
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.remove('email_sent');
          emailLink = false;
          setState(() {});
        },
        child: const Text(
          'Log Out',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 180,
                    child: Image.asset(
                      "assets/warehouse.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: Text(
                      "Welcome $userName",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                  ),
                  logOutButton,
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
