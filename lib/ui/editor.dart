
import 'package:flutter/material.dart';
import 'package:crescent_masjid/util/util.dart';



class Editor extends StatefulWidget {

  Editor({Key key }) : super(key : key);

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {

  String dropdownValue = 'fajr';
  String hoursVal = '12',minutesVal = '00';
  String hoursEndVal = '12' , minuteEndVal = '00';
  bool opac = true;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Edit Timings"),
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
                padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[

                    new Text("Timinng  " ,style: new TextStyle(color: Colors.blueAccent),),

                    DropdownButton<String>(
                      value: dropdownValue,
                      onChanged: (String newValue) {

                        visibleButtons(newValue);

                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: timingList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,style: new TextStyle(color: Colors.blueAccent)),
                        );
                      })
                          .toList(),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
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
                        child: Text(value ,style: new TextStyle(color: Colors.blueAccent),),
                      );
                    })
                        .toList(),
                  ),
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
                        child: Text(value,style: new TextStyle(color: Colors.blueAccent)),
                      );
                    })
                        .toList(),
                  ),

                ],
              ),

              getOptionalWidget(opac),


              new ListTile(

                title: new FlatButton(
                    color: Colors.blueAccent.shade100,
                    splashColor: Colors.blueAccent,
                    onPressed: (){

                      Navigator.pop(context ,{
                        'hour' : hoursVal,
                        'hoursEndVal':hoursEndVal,
                        'minuteEndVal':minuteEndVal ,
                        'minute' : minutesVal,
                        'timing':dropdownValue
                      });
                    },
                    child: new Text("save data" , style: new TextStyle(color: Colors.white,fontSize: 15.0),)),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget getOptionalWidget(bool opac) {

    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[

        Visibility(
          visible:opac==null?true:opac,
          child: DropdownButton<String>(
            value: hoursEndVal,
            onChanged: (String newValue) {
              setState(() {
                hoursEndVal = newValue;
              });
            },
            items: hoursList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,style: new TextStyle(color: Colors.blueAccent)),
              );
            })
                .toList(),
          ),
        ),
        Visibility(
          visible:opac==null?true:opac,
          child: DropdownButton<String>(
            value: minuteEndVal,
            onChanged: (String newValue) {
              setState(() {
                minuteEndVal = newValue;
              });
            },
            items: minutesList
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value,style: new TextStyle(color: Colors.blueAccent)),
              );
            })
                .toList(),
          ),
        ),

      ],

    );

  }

  void visibleButtons(String newValue) {
    int flag = 0;
    for(var i = 0;i<oneList.length;i++){
      if(newValue == oneList[i]){
        print("make invisible");
       flag = 1;
      }
    }
    if(flag == 1){
      setState(() {
        opac = false;
      });
    }
    else {
      setState(() {
        opac = true;
      });
    }
  }

}






















