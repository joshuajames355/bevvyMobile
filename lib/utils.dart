import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:flutter/material.dart';

String getDateText(DateTime date)
{
  DateTime now = DateTime.now();
  if(now.year == date.year && now.month == date.month && now.day == date.day) //If Today
  {
    return "Today at " + DateFormat("jm").format(date); 
  }
  now = now.subtract(Duration(days: 1));
  if(now.year == date.year && now.month == date.month && now.day == date.day) //If Today
  {
    return "Yesterday at " + DateFormat("jm").format(date); 
  }
  return DateFormat("dd-MM-yyyy").format(date);
}

double degToRad(double deg)
{
  return deg * pi/180;
}

//lat and lon in degrees, returns an answer in metres
double distBetweenPoints(double lat1, double lon1, double lat2, double lon2)
{
  var earthRadius = 6378137.0; // WGS84 major axis
  return 2 * earthRadius * asin(
      sqrt(
          pow(sin( (degToRad(lat2) - degToRad(lat1))/2), 2)
              + cos(degToRad(lat1))
              * cos(degToRad(lat2))
              * pow(sin(degToRad(lon1) - degToRad(lon2)) / 2, 2)
      )
  );
}

Widget getCardBrandIcon(String brand)
{
  if (brand == null || brand == "") return Icon(FontAwesomeIcons.creditCard);
  if(brand.toLowerCase() == "visa") return Icon(FontAwesomeIcons.ccVisa);
  if(brand.toLowerCase() == "amex") return Icon(FontAwesomeIcons.ccAmex);
  if(brand.toLowerCase() == "mastercard") return Icon(FontAwesomeIcons.ccMastercard);
  return Icon(FontAwesomeIcons.creditCard);
}