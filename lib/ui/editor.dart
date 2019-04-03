
import 'package:flutter/material.dart';


class Editor extends StatefulWidget {



  Editor({Key key }) : super(key : key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {


  var _hour = new TextEditingController();
  var _minut  = new TextEditingController();
  String dropdownValue = 'sehari';

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

          new ListTile(
            title: new TextField(
              controller: _hour,
              decoration: new InputDecoration(
                labelText: "Hour ",
                hintText: '12'
              ),
            ),
          ),

          new ListTile(
            title: new TextField(
              controller: _minut,
              decoration: new InputDecoration(
                labelText: "Minutes ",
                hintText: '00'
              ),
            ),
          ),
          new ListTile(
            title: new FlatButton(
                onPressed: (){
                  Navigator.pop(context ,{
                    'hour' : _hour.text.toString(),
                    'minute' : _minut.text.toString(),
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






















