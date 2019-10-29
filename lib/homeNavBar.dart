import 'package:flutter/material.dart';

class HomeNavBar extends StatelessWidget 
{
  const HomeNavBar({ Key key, this.currentIndex}) :  super(key: key);

  final int currentIndex;
  
  @override
  Widget build(BuildContext context)
  {
    return BottomNavigationBar
    (
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).accentColor,
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem
        (
          title: Text("Home"),
          icon: Icon(IconData(59530, fontFamily: 'MaterialIcons')),
        ),
        BottomNavigationBarItem
        (
          title: Text("Basket"),
          icon: Icon(IconData(59596, fontFamily: 'MaterialIcons')),
        ),
        BottomNavigationBarItem
        (
          title: Text("Account"),
          icon: Icon(IconData(59473, fontFamily: 'MaterialIcons')),
        ),
        BottomNavigationBarItem
        (
          title: Text("Orders"),
          icon: Icon(IconData(59485, fontFamily: 'MaterialIcons')),
        ),
      ],
      onTap: (int page){
        switch(page){
          case 0:
            Navigator.pushNamedAndRemoveUntil(context, '/home', (Route<dynamic> route) => false);
            return;
          case 1:
            Navigator.pushNamed(context, "/basket");
            return;
          case 2:
            Navigator.pushNamed(context, "/accountDetails");
            return;
          case 3:
            Navigator.pushNamed(context, "/myOrders");
            return;
        }
      },
    );
  }
}