import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:redback_mobile_app/Account.dart';
import 'package:redback_mobile_app/screens/info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {

  late String username, firstname, lastname;
  // Obtain shared preferences.
  late SharedPreferences prefs;
  getSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  // SharedPreferences must be initialized before getUser to store preferences
  initialize() async {
    await getSharedPreferences();
    await getUser(true);
  }

  // refresh the authentication tokens - runs on initialization
  refreshToken() async {
    var client = http.Client();
    // use 127.0.0.1 when testing with a browser and 10.0.2.2 when testing with the emulator
    var response = await client.post(Uri.parse('http://10.0.2.2:8080/refreshToken'),
        headers: {"Content-Type": "application/json; charset=utf-8"},
        body: jsonEncode({
          "token": prefs.getString("refreshToken"),
        }));
    if (response.statusCode == 200) {
      var values = json.decode(response.body);
      prefs.setString("accessToken", values["accessToken"]);
      prefs.setString("refreshToken", values["refreshToken"]);
    }
  }

  // Obtain and saves up-to-date user details (must be logged in with valid credentials) - runs on initialization
  getUser(bool loop) async {
    try {
      var client = http.Client();
      var username = prefs.getString('username');
      var accessToken = prefs.getString('accessToken');
      // Obtain and save user details
      // use 127.0.0.1 when testing with a browser and 10.0.2.2 when testing with the emulator
      var response = await client.get(Uri.parse('http://10.0.2.2:8080/user/$username'),
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Authorization": "Bearer $accessToken"},
      );
      if (response.statusCode == 200) {
        // update all values
        var userValues = jsonDecode(response.body);
        prefs.setString("_id", userValues["_id"]);
        prefs.setString("username", userValues["username"]);
        prefs.setString("firstname", userValues["firstname"]);
        prefs.setString("lastname", userValues["lastname"]);
        prefs.setString("email", userValues["email"]);
        prefs.setString("password", userValues["password"]);
        prefs.setInt("redbackCoins", userValues["redbackCoins"]);
        prefs.setInt("telephone", userValues["telephone"]);
        prefs.setInt("userLevel", userValues["userLevel"]);
        client.close();
      } else if (loop) {
        // if failed becaused of token, refresh token first then repeat
        await refreshToken();
        await getUser(false);
      } else {
        print("Error: Invalid refresh token. Require re-login");
      }
    } catch (e) {
      print(e);
    }
    
  }

  // get username for Future<String> instances - ensures that username data is populated before loading text in widget
  Future<String> getUsername() async {
    await getSharedPreferences();
    username = prefs.getString("username")!;
    return username;
  }

  // get full name for Future<String> instances - ensures that name data is populated before loading text in widget
  Future<String> getFullname() async {
    await getSharedPreferences();
    firstname = prefs.getString("firstname")!;
    lastname = prefs.getString("lastname")!;
    return firstname + " " + lastname;
  }

  // initialize SharedPreferences and tokens
  @override
  void initState() {
    super.initState();
    initialize();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundCloor: Color.fromARGB(255, 104, 75, 182),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 75, 182),
        elevation: 0,
        centerTitle: true,
        title: const Text('R E D B A C K'),
      ),
      body: Center(
        // show Future<String> text for username, only shows when username data has been obtained
        child: FutureBuilder<String>(
          future: getFullname(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return const Text('Error');
              } else if (snapshot.hasData) {
                return Text(
                'Welcome ${snapshot.data}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 230, 152, 129),
                  )
                );
              } else {
                return const Text('Empty data');
              }
            } else {
              return Text('State: ${snapshot.connectionState}');
            }
          }
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: const Color.fromARGB(255, 230, 152, 129),
          child: ListView(
            children: [
              const DrawerHeader(
                  child: Center(
                child: Text(
                  'REDBACK',
                  style: TextStyle(fontSize: 30),
                ),
              )),
              // "welcome [user]" in hamburger menu
              ListTile(
                title: FutureBuilder<String>(
                  future: getUsername(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasError) {
                        return const Text('Error');
                      } else if (snapshot.hasData) {
                        return Text(
                        'Welcome $username',
                        style: const TextStyle(fontSize: 20),
                        );
                      } else {
                        return const Text('Empty data');
                      }
                    } else {
                      return Text('State: ${snapshot.connectionState}');
                    }
                  }
                ),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_rounded),
                title: const Text(
                  'Profile',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  // Here we will navigate to the accounts page
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Account(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.history_edu_rounded),
                title: const Text(
                  'Fitness History',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  // Here we will navigate to the accounts page
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const InformationPage(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text(
                  'Settings',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  // Here we will navigate to the accounts page
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Account(),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_gmailerrorred),
                title: const Text(
                  'Report an Issue',
                  style: TextStyle(fontSize: 20),
                ),
                onTap: () {
                  // Here we will navigate to the accounts page
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const Account(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color.fromARGB(255, 230, 152, 129),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: GNav(
              backgroundColor: Color.fromARGB(255, 230, 152, 129),
              color: Color.fromARGB(183, 255, 255, 255),
              activeColor: Color.fromARGB(255, 130, 235, 182),
              tabBackgroundColor: Color.fromARGB(55, 114, 243, 153),
              gap: 10,
              padding: EdgeInsets.all(16),
              tabs: [
                GButton(
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.favorite_rounded,
                  text: 'Friends',
                ),
                GButton(
                  icon: Icons.account_circle_rounded,
                  text: 'Profile',
                ),
              ]),
        ),
      ),
    );
  }
}
