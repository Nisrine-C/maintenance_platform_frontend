import 'package:flutter/material.dart';
import 'package:maintenance_platform_frontend/screen/appBar/home.dart';
import 'package:maintenance_platform_frontend/screen/machines/machines.screen.dart';

final Map<String,WidgetBuilder>appRoutes={
  '/dashbord' : (context) => HomeBar(),
  '/machines' : (context) => MachinesScreen(),

};