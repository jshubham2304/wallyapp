import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wallyapp/config.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Image(
                image: AssetImage('assets/bg.jpg'),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.cover,
              ),
              Container(
                  margin: EdgeInsets.only(
                    top: 100,
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Image(
                    image: AssetImage('assets/logo_circle.png'),
                    width: 180,
                    height: 180,
                  )),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.black, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter)),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    width: MediaQuery.of(context).size.width,
                    child: InkWell(
                      onTap: googleSignIn,
                      child: Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                                colors: [primaryColor, secondaryColor])),
                        child: Center(
                            child: Text(
                          "Google Sign In",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontFamily: "productsans"),
                        )),
                      ),
                    )),
              )
            ],
          )),
    );
  }

  void googleSignIn() async {
    try {
 final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
    
    _db.collection("users").document(user.uid).setData({
        "displayName":user.displayName,
        "email":user.email,
        "uid":user.uid,
        "photoUrl":user.photoUrl,
        "lastSignIn":DateTime.now()
    },merge: true
      
    );
    } catch (e) {
      print(e);
    }
  }
}
