import 'package:flutter/material.dart';

PreferredSizeWidget buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    title: const Text("Home"),
    actions: [
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Setting Icon',
        onPressed: () {},
      ),
    ],
    foregroundColor: const Color.fromARGB(255, 6, 6, 6),
    elevation: 50.0,
    leading: Builder(
      builder:
          (context) => IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu Icon',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
    ),
  );
}

Drawer buildHomeDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text(
            'Menu',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          onTap: () => Navigator.pushNamed(context, '/dashbord'),
        ),
        ListTile(
          leading: const Icon(Icons.precision_manufacturing),
          title: const Text('Machine Detail Screen'),
          onTap: () => Navigator.pushNamed(context, '/machines'),
        ),
        ListTile(
          leading: const Icon(Icons.build),
          title: const Text('Maintenance Management'),
          onTap: () => Navigator.pushNamed(context, '/maintenance'),
        ),
      ],
    ),
  );
}
