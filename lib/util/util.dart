
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


