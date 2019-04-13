


import 'package:crescent_masjid/ui/salah_timer.dart';
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
        title: new Text("Enter Location"),
      ),
      body: new Stack(
        children : <Widget>[

        new Image.asset(
            'images/city.jpg',
            width: 1200.0,
            height: 1200.0,
            fit: BoxFit.cover,
        ),

        Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextField(

                  controller: _countryController,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      labelText: 'Country',
                      hintText: 'India',
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextField(
                  controller: _cityController,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      labelText: 'City',
                      hintText: 'Hyderabad',
                  ),
                ),
              ),
              new ListTile(

                title: new FlatButton(
                  color: Colors.blueAccent.shade100,
                  splashColor: Colors.blueAccent,
                    onPressed: (){

                      Navigator.of(context).push(
                          new MaterialPageRoute<Map>(
                              builder: (BuildContext context){
                                return new Salah(city :_cityController.text.isEmpty ? "Hyderabad" :_cityController.text
                                    ,country: _countryController.text.isEmpty ? "India" :_countryController.text);
                              })
                      );
                    },
                    child: new Text("Search" ,style: new TextStyle(color: Colors.white,fontSize: 15.0),) ),
              ),
            ],
        ),


        ],
      ),
    );
  }


}







































