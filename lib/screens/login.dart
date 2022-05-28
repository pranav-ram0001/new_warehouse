import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:new_warehouse/main.dart';
import 'package:new_warehouse/screens/firebasehandler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_mail_app/open_mail_app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();

  // editing controller
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // email field
    final emailField = Visibility(
      visible: !emailLink,
      child: TextFormField(
        autofocus: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        onSaved: (value) {
          emailController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.mail),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Email",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
    // password field
    final passwordField = Visibility(
      visible: !emailLink,
      child: TextFormField(
        autofocus: false,
        controller: passwordController,
        obscureText: true,
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.vpn_key),
            contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            hintText: "Password",
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );

    final loginButton = Visibility(
      visible: !emailLink,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(30),
        color: Colors.teal,
        child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () async {
            final authResult = FirebaseAuth.instance
                .signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text)
                .catchError((error) => print(error.code));
            if (authResult != null) {
              Future<UserCredential> firebaseUser = authResult;
              if (firebaseUser != null) {
                var user = FirebaseAuth.instance.currentUser;
                print("Log In: ${user?.email}");
                print('Success');
                setState(() {});
              }
            }
          },
          child: const Text(
            'Login',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    final sendEmailButton = Visibility(
      visible: !emailLink,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(30),
        color: Colors.teal,
        child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () async {
            var acs = ActionCodeSettings(
                url: 'https://pranavramanathanwarehouse.page.link/signIn',
                handleCodeInApp: true,
                iOSBundleId: 'com.example.ios',
                androidPackageName:
                    'com.pranavramanathan.warehouse_2.new_warehouse',
                androidInstallApp: true,
                androidMinimumVersion: '12');

            emailAuth = emailController.text.trim();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString("emailAuth", emailAuth);
            FirebaseAuth.instance
                .sendSignInLinkToEmail(
                    email: emailAuth, actionCodeSettings: acs)
                .catchError((onError) =>
                    print('Error sending email verification $onError'))
                .then((value) => prefs.setString('email_sent', 'y'))
                .then((value) => emailLink = true);
            var result = await OpenMailApp.openMailApp(
              nativePickerTitle: 'Select email app to open',
            );

            if (!result.didOpen && result.canOpen) {
              showDialog(
                context: context,
                builder: (_) {
                  return MailAppPickerDialog(
                    mailApps: result.options,
                  );
                },
              );
            }

            setState(() {});
          },
          child: const Text(
            'Send Email',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
    final loginEmailLinkButton = Visibility(
      visible: emailLink,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(30),
        color: Colors.teal,
        child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () async {
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
              FirebaseAuth.instance.signInWithEmailLink(
                  email: emailAuth, emailLink: '$deepLink');
            } catch (e) {}
          },
          child: const Text(
            'Log In',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    child: Image.asset("assets/warehouse.png",
                        fit: BoxFit.contain),
                  ),
                  const SizedBox(
                    height: 45,
                  ),
                  emailField,
                  const SizedBox(
                    height: 25,
                  ),
                  passwordField,
                  const SizedBox(
                    height: 35,
                  ),
                  loginButton,
                  const SizedBox(
                    height: 15,
                  ),
                  sendEmailButton,
                  const SizedBox(
                    height: 15,
                  ),
                  loginEmailLinkButton,
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      )),
    );
  }
}
