import 'package:bevvymobile/product.dart';
import "package:bevvymobile/productWidget.dart";
import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/material.dart';

//Renders a List of all products, seperated by categories.
class SearchResults extends StatefulWidget
{
  const SearchResults({ Key key, this.productList}) : super(key: key);

  final List<Product> productList;

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults>
{
  //Ensures no search results before the user submits a new searchQuery
  String searchQuery = "_zgx@-~|ab23dA[";
  var fuzzyComp = Damerau();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold
    (
      appBar: AppBar
      (
        automaticallyImplyLeading: false,
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 5)
            ),
            labelText: 'Search',
          ),
          onSubmitted: (String text){
            setState(() {
             searchQuery = text; 
            });
          },   
        ),
        leading: FlatButton
        (
          child: Icon(IconData(58820, fontFamily: 'MaterialIcons')),
          onPressed: ()
          {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView
      (
        padding: EdgeInsets.symmetric(vertical: 10),
        children: widget.productList.where((Product x){
            return fuzzyComp.distance(x.title.toLowerCase(), searchQuery.toLowerCase()) < 5 || 
                    x.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    fuzzyComp.distance(x.category.toLowerCase(), searchQuery.toLowerCase()) < 3;
          }).map((Product x) {
            return ProductWidget(product: x, );
          }).toList()
      )
    );
  }
}