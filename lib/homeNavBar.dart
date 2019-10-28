import 'package:flutter/material.dart';

class HomeNavBar extends StatelessWidget 
{
  const HomeNavBar({ Key key}) :  super(key: key);
  
  @override
  Widget build(BuildContext context)
  {
    return BottomNavigationBar
    (
      items: [
        BottomNavigationBarItem
        (
          title: Text("Home"),
          icon: Icon(IconData(59530, fontFamily: 'MaterialIcons')),
        ),
        BottomNavigationBarItem
        (
          title: Text("My Account"),
          icon: Icon(IconData(59473, fontFamily: 'MaterialIcons')),
        ),
        BottomNavigationBarItem
        (
          title: Text("My Orders"),
          icon: Icon(IconData(59485, fontFamily: 'MaterialIcons')),
        ),
      ],
      onTap: (int page){
        switch(page){
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
            return;
          case 1:
            Navigator.pushNamed(context, "/accountDetails");
            return;
          case 2:
            Navigator.pushNamed(context, "/myOrders");
            return;
        }
      },
    );
  }
}