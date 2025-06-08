import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/appBar/appBar.dart';
import 'package:maintenance_platform_frontend/widget/dashbord/dashbord_secsion.dart';


class DashbordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      drawer: buildHomeDrawer(context),
      body: DashboardSecsion(),
    );
  }
}
