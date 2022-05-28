import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:new_warehouse/screens/firebasehandler.dart';
import 'package:new_warehouse/screens/login.dart';
import 'package:new_warehouse/screens/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

late String userName;
bool emailLink = false;
var emailAuth = "";
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  userName = FirebaseAuth.instance.currentUser?.email ?? "";
  String emailSent = prefs.getString('email_sent') ?? "n";
  if (emailSent == 'y') {
    emailLink = true;
  }
  if (emailLink == true) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('email_sent');
    emailAuth = prefs.getString("emailAuth") ?? "no email";
    print(emailAuth);
    try {
      FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
        final Uri? deepLink = dynamicLink.link;
        if (deepLink != null) {
          handleLink(deepLink, emailAuth);
          FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) {
            final Uri? deepLink = dynamicLink.link;
            handleLink(deepLink!, emailAuth);
          }, onError: (e) async {
            print(e.message);
          });
        }
      }, onError: (e) async {
        print(e.message);
      });

      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();
      final Uri? deepLink = data?.link;
      print('deepLink :: $deepLink');
      FirebaseAuth.instance
          .signInWithEmailLink(email: emailAuth, emailLink: '$deepLink');
    } catch (e) {}
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'warehouse',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
