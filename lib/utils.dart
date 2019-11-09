import 'package:intl/intl.dart';
import 'dart:math';

String getDateText(DateTime date)
{
  DateTime now = DateTime.now();
  if(now.year == date.year && now.month == date.month && now.day == date.day) //If Today
  {
    return DateFormat("jm").format(date); 
  }
  now = now.subtract(Duration(days: 1));
  if(now.year == date.year && now.month == date.month && now.day == date.day) //If Today
  {
    return "Yesterday"; 
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
          pow(sin( degToRad(lat1) - degToRad(lat2)) / 2, 2)
              + degToRad(lat1)
              * degToRad(lat2)
              * pow(sin(degToRad(lon1) - degToRad(lon2)) / 2, 2)
      )
  );
}