import 'package:flutter/material.dart';

class NetWorkPage extends StatelessWidget {
  const NetWorkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [SliverAppBar(title: Text("网络"))]),
    );
  }
}
