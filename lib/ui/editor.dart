
import 'package:flutter/material.dart';
import 'package:crescent_masjid/util/util.dart';






class Editor extends StatefulWidget {

  Editor({Key key }) : super(key : key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {


  String dropdownValue = 'sehari';
  String hoursVal = '12',minutesVal = '00';

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Edit Timings"),
      ),
      body: new ListView(
        children : <Widget>[

          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
              });
            },
            items: <String>['sehari', 'fajr', 'zohar', 'asar','iftiyaari','magrib', 'isha']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            })
                .toList(),
          ),

          DropdownButton<String>(
            value: hoursVal,
            onChanged: (String newValue) {
              setState(() {
                hoursVal = newValue;
              });
            },
            items:hoursList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            })
                .toList(),
          ),
//
          DropdownButton<String>(
            value: minutesVal,
            onChanged: (String newValue) {
              setState(() {
                minutesVal = newValue;
              });
            },
            items: minutesList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            })
                .toList(),
          ),

          new ListTile(
            title: new FlatButton(
                onPressed: (){
                  Navigator.pop(context ,{
                    'hour' : hoursVal,
                    'minute' : minutesVal,
                    'timing':dropdownValue
                  });
                },
                child: new Text("send data back !")),
          ),
        ],
      ),
    );
  }

}






















