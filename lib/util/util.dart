
import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:percent_indicator/percent_indicator.dart';

import 'package:flutter/material.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;

DatabaseReference dbReference;

final FirebaseMessaging messaging =  FirebaseMessaging();

String  sehari ,fajr , zohar , asar ,iftiyaari, magrib , isha  , sub = "subscribed";


Widget getProgressCircle(double progress, double percent, bool opac ) {

  return Visibility(
    visible: opac==null?true:opac,
    child: new CircularPercentIndicator(
      radius: 120.0,
      lineWidth: 13.0,
      animation: true,
      percent: progress,
      center: new Text(
        "$percent %",
        style:
        new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      footer: new Text(
        "Fetching data !!",
        style:
        new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
      ),
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: Colors.lightBlue,
    ),
  );
}

String title =  "Crescent Masjid";

List<String> hoursList =  <String>['01','02','03','04','05','06','07','08','09','10','11','12'];

List<String> timingList =  <String>['sehari','fajr','sunrise',
                                     'zohar',
                                    'asar','iftiyaari','sunset',
                                    'magrib',
                                    'isha', 'taraweeh'];

List<String> minutesList =  <String>['00','01','02','03','04','05','06','07','08','09','10',
                                 '11','12','13','14','15','16','17','18','19','20',
                                 '21','22','23','24','25','26','27','28','29','30',
                                 '31','32','33','34','35','36','37','38', '39','40',
                                 '41','42','43','44','45','46','47','48','49','50',
                                 '51','52','53','54','55','56','57','58','59'];

List<String> oneList = <String>['sehari','sunrise','sunset','iftiyaari','taraweeh'];



Widget getNoConnectionWidget(){

  return Padding(
    padding: const EdgeInsets.fromLTRB(0,50.0,0,0),
    child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children:<Widget>[

          new Image.asset(
            'images/no-wifi.png',
            width: 100.0,
            height: 100.0,
            fit: BoxFit.fill,
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(0,10.0,0,0),
            child: new Text("No Internet Connection", style: new TextStyle(color: Colors.blueAccent ,fontWeight: FontWeight.bold,height: 2.0 ,fontSize: 15.0),),
          ),

        ]
    ),
  );

}










