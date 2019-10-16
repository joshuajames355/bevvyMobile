import 'package:flutter/material.dart';
import 'package:bevvymobile/product.dart'; 

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget
{
  const HomeAppBar({ Key key, this.productList}) : preferredSize = const  Size.fromHeight(kToolbarHeight), super(key: key);

  final List<Product> productList;

  @override
  final Size preferredSize;
  
  @override
  _HomeAppBarState createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> 
{
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return AppBar
    (
      leading: FlatButton
      (
        child: Icon(IconData(58834, fontFamily: 'MaterialIcons')),
        onPressed: ()
        {
          Scaffold.of(context).openDrawer();
        },
        padding: EdgeInsets.all(2),
      ),
      title: TextField
      (
        decoration: InputDecoration
        (
          border: UnderlineInputBorder(),
          labelText: 'Search',
          icon: Icon
          (
            IconData(59574, fontFamily: 'MaterialIcons'),
            size: 30
          ),
        ),
        style: TextStyle
        (
          fontSize: 24,
        ),
        controller: _controller,
        onSubmitted: (String currentText) => Navigator.pushNamed(context, "/search", arguments: widget.productList.where((Product x)
          {
            return x.title.toLowerCase().contains(_controller.text.toLowerCase());
          }).toList()),
      ),
      actions: 
      [
        IconButton
        (
          onPressed: (){},
          icon: Icon
          (
            IconData(57682, fontFamily: 'MaterialIcons'),
            size: 30
          ),
        )
      ],
    );
  }
}