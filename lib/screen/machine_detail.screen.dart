import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class Detail extends StatelessWidget {
  final String machine;

  const Detail({Key? key, required this.machine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$machine Details")),
      body: Center(
        child: Text('This is the details page for $machine'),
      ),
    );
  }
}