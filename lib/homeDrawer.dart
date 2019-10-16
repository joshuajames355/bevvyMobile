import 'package:flutter/material.dart';
import 'package:bevvymobile/globals.dart';

class HomeDrawer extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
    return SizedBox
    (
      width: 200,
      child: Drawer
      (
        child: Column
        (
          children: 
          [
            DrawerHeader
            (
              child: Image
              (
                height: 100,
                width: 100,
                image: AssetImage
                (
                  'images/logo.png',
                ),
              ),
            ),
            ListTile
            (
              title: Text("Home"),
              trailing: Icon(IconData(59530, fontFamily: 'MaterialIcons')),
              onTap: ()
              {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
              },
            ),
            ListTile
            (
              title: Text("My Account"),
              trailing: Icon(IconData(59473, fontFamily: 'MaterialIcons')),
              onTap: ()
              {
                Navigator.popAndPushNamed(context, "/accountDetails");
              },
            ),
            Expanded(child: Container(),),
            ListTile
            (
              title: Text("Log out"),
              trailing: Icon(IconData(59513, fontFamily: 'MaterialIcons')),
              onTap: ()
              {
                auth.signOut();
              },
            ),
          ]
        ),
      )
    );
  }
}