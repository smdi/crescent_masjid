


import 'package:flutter/material.dart';
import 'package:crescent_masjid/util/util.dart';



class Search extends StatefulWidget {

  Search({Key key }) : super(key : key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {

  String dropdownValue = 'fajr';
  String hoursVal = '12',minutesVal = '00';
  String hoursEndVal = '12' , minuteEndVal = '00';
  bool opac = true;

  final TextEditingController _countryController = new TextEditingController();
  final TextEditingController _cityController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Edit Timings"),
      ),
      body: new ListView(
        children : <Widget>[

          new TextField(
            controller: _countryController,
            keyboardType: TextInputType.text,
            decoration: new InputDecoration(
                labelText: 'Country',
                hintText: 'India',
                icon: new Icon(Icons.person_outline)),
          ),

          new TextField(
            controller: _cityController,
            keyboardType: TextInputType.text,
            decoration: new InputDecoration(
                labelText: 'City',
                hintText: 'Hyderabad',
                icon: new Icon(Icons.person_outline)),
          ),

          new ListTile(
            title: new FlatButton(
                onPressed: (){
                  Navigator.pop(context ,{
                    'city' : _cityController.text.isEmpty ? "Hyderabad" : _cityController.text,
                    'country': _countryController.text.isEmpty ? "India" : _countryController.text,
                  });
                },
                child: new Text("send data back !")),
          ),

        ],
      ),
    );
  }



}






































