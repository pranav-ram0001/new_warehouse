import 'package:firebase_auth/firebase_auth.dart';

class EmailLinkService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithEmailAndLink({required String userEmail}) async {
    var _userEmail = userEmail;
    var acs = ActionCodeSettings(
        url: 'https://pranavramanathanwarehouse.page.link/signIn',
        handleCodeInApp: true,
        iOSBundleId: 'com.example.ios',
        androidPackageName: 'com.pranavramanathan.warehouse_2.new_warehouse',
        androidInstallApp: true,
        androidMinimumVersion: '12');
    try {
      return await _auth.sendSignInLinkToEmail(
          email: _userEmail, actionCodeSettings: acs);
    } on FirebaseAuthException catch (e) {}
  }

  void handleLink(Uri link, userEmail) async {
    if (link != null) {
      final UserCredential user =
          await FirebaseAuth.instance.signInWithEmailLink(
        email: userEmail,
        emailLink: link.toString(),
      );
    } else {
      print(" link is null");
    }
  }
}

Future<void> handleLink(Uri link, userEmail) async {
  if (link != null) {
    final UserCredential user = await FirebaseAuth.instance.signInWithEmailLink(
      email: userEmail,
      emailLink: link.toString(),
    );
  } else {
    print(" link is null");
  }
}
