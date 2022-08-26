// ignore_for_file: avoid_print

import 'dart:convert';
//import 'dart:js_util';
import 'package:flutter/material.dart';
import 'package:redback_mobile_app/screens/signUp.dart';
import 'package:redback_mobile_app/screens/homePage.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Obtain shared preferences.
late SharedPreferences prefs;
getSharedPreferences() async {
  prefs = await SharedPreferences.getInstance();
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // our form key
  final _formKey = GlobalKey<FormState>();
  final userNameEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();

  late var userNameField;
  late var passwordField;

  

  Future<void> getData() async {
    getSharedPreferences();
    try {
      var client = http.Client();
      // use 127.0.0.1 when testing with a browser and 10.0.2.2 when testing with the emulator
      var response = await client.post(Uri.parse('http://10.0.2.2:8080/login'),
          headers: {"Content-Type": "application/json; charset=utf-8"},
          body: jsonEncode({
            "username": userNameEditingController.text,
            "password": passwordEditingController.text,
          }));
      //If the information is correct, you will be redirected to the home page
      //If there is an error message, there will be an alert box to indicate
      // that the account number or password is incorrect
      if (response.statusCode == 200) {
        var values = json.decode(response.body);
        //save accessToken and refreshToken in sharedPreferences memory
        prefs.setString("accessToken", values["accessToken"]);
        prefs.setString("refreshToken", values["refreshToken"]);
        var accessToken = values["accessToken"];
        var username = userNameEditingController.text;
        // Obtain and save user details after verified login for future pages
        response = await client.get(Uri.parse('http://10.0.2.2:8080/user/$username'),
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          "Authorization": "Bearer $accessToken"},
        );
        if (response.statusCode == 200) {
          var userValues = json.decode(response.body);
          prefs.setString("_id", userValues["_id"]);
          prefs.setString("username", userValues["username"]);
          prefs.setString("firstname", userValues["firstname"]);
          prefs.setString("lastname", userValues["lastname"]);
          prefs.setString("email", userValues["email"]);
          prefs.setString("password", userValues["password"]);
          prefs.setInt("redbackCoins", userValues["redbackCoins"]);
          prefs.setInt("telephone", userValues["telephone"]);
          prefs.setInt("userLevel", userValues["userLevel"]);
        }
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                )));
      } else {
        //The style also needs to be set
        Fluttertoast.showToast(
          msg: response.body,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      client.close();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // username field
    userNameField = TextFormField(
        autofocus: false,
        controller: userNameEditingController,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          fillColor: const Color(0xFFe87461),
          filled: true,
          prefixIcon: const Icon(Icons.account_circle),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "User Name",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //password field
    passwordField = TextFormField(
        autofocus: false,
        controller: passwordEditingController,
        obscureText: true,
        textInputAction: TextInputAction.next,
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        decoration: InputDecoration(
          fillColor: const Color(0xFFe87461),
          filled: true,
          prefixIcon: const Icon(Icons.vpn_key),
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    //login button
    final logInButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: const Color(0xFFe87461),
      child: MaterialButton(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: getData,
          child: const Text(
            "Log In",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          )),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(56, 14, 74, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFe87461)),
          onPressed: () {
            //passing this to our root
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            color: const Color.fromRGBO(56, 14, 74, 1),
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //Image.asset('assets/images/Logo.png'),
                    SizedBox(
                        height: 180,
                        //image logo
                        child: Image.asset(
                          'assets/images/BLogo.png',
                          fit: BoxFit.contain,
                        )),
                    const SizedBox(height: 45),
                    userNameField,
                    const SizedBox(height: 20),
                    passwordField,
                    const SizedBox(height: 20),
                    logInButton,
                    const SizedBox(height: 15),
                    const SizedBox(height: 13),
                    TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                            fontSize: 12, color: Color(0xFFe87461)),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Forgot Password ?",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Don't have an Account? ",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen()));
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Color(0xFFe87461),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          )
                        ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String text, String text2) {}
}
