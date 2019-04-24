import 'package:crescent_masjid/ui/home.dart';
import 'package:crescent_masjid/util/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main(){

  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(
        new MaterialApp(
          color: Colors.grey,
          home: new Home(),
        )
    );
  });


  
}