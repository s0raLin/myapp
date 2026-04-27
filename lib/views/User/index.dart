import 'package:flutter/material.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(),
                    Column(children: [Text("data"), Text("vip")]),
                  ],
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
