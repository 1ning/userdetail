import 'package:flutter/material.dart';

class InformationPage extends StatelessWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 104, 75, 182),
        elevation: 0,
        centerTitle: true,
        title: Text('R E D B A C K'),
      ),
      body: Center(
        child: Text('INFORMATION PAGE'),
      ),
    );
  }
}