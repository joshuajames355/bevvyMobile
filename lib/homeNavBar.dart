import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeNavBar extends StatefulWidget 
{
  const HomeNavBar({ Key key, this.navKey}) :  super(key: key);

  final GlobalKey<NavigatorState> navKey;

  @override
  _HomeNavBarState createState() => _HomeNavBarState();
}

class _HomeNavBarState extends State<HomeNavBar> {
  int lastSelected = 0;

  @override
  Widget build(BuildContext context)
  {
    return CupertinoTabBar
    (
      currentIndex:  lastSelected,
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
        setState(() {
          lastSelected = page;
        });
        if(widget.navKey != null)
        {
          switch(page){
            case 0:
              widget.navKey.currentState.pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
              return;
            case 1:
              widget.navKey.currentState.pushNamed("/basket");
              return;
            case 2:
              widget.navKey.currentState.pushNamed("/accountDetails");
              return;
            case 3:
              widget.navKey.currentState.pushNamed("/myOrders");
              return;
          }
        }
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