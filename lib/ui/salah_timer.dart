
import 'dart:convert';
import 'package:crescent_masjid/util/util.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';





class Salah extends StatefulWidget {

  String city = "" , country = "";
  Salah( {Key key ,this.city , this.country }) : super(key : key);

  @override
  _SalahState createState() => _SalahState();
}

class _SalahState extends State<Salah> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicator = new GlobalKey<RefreshIndicatorState>();

  var _connection = false , opac;
  double percent , progress ;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicator.currentState.show());

    stateSetter(20.0, 0.2, true);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("${widget.country} - ${widget.city}"),
      ),
      body:
      RefreshIndicator(
        key: _refreshIndicator,
        onRefresh: _checkConnectivity,
        child: new ListView(
          children : <Widget>[

            getProgressCircle(percent,progress,opac),
            getWidget(_connection, widget),

          ],
        ),
      ),
    );
  }

  Future<Map> getTimings(String city, String country) async {

    String api = "http://api.aladhan.com/timingsByCity?city=$city&country=$country&method=8";

    http.Response response = await http.get(api);


    stateSetter(50, 0.5, true);

    stateSetter(70, 0.7, true);

    stateSetter(100, 1.0, false);

    return  json.decode(response.body);

  }

  Widget getWidget(bool connectivity, Salah widget) {


    if(connectivity) {
      stateSetter(100, 1.0, false);
      return new FutureBuilder(
          future: getTimings(widget.city, widget.country),
          builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
            if (snapshot.hasData) {
              Map content = snapshot.data;

              return new Column(
                children: <Widget>[

                  getCard("Fajr", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Fajr'].toString(),
                      content['data']['meta']['timezone'].toString()),

                  getCard("Sunrise", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Sunrise'].toString(),
                      content['data']['meta']['timezone'].toString()),

                  getCard("Zohar", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Dhuhr'].toString(),
                      content['data']['meta']['timezone'].toString()),

                  getCard("Asar", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Asr'].toString(),
                      content['data']['meta']['timezone'].toString()),

                  getCard("Sunset", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Sunset'].toString(),
                      content['data']['meta']['timezone'].toString()),

                  getCard("Maghrib", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Maghrib'].toString(),
                      content['data']['meta']['timezone'].toString()),

                  getCard("Isha", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Isha'].toString(),
                      content['data']['meta']['timezone'].toString()),

                  getCard("Imsak", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Imsak'].toString(),
                      content['data']['meta']['timezone'].toString()),

                  getCard("Midnight", content['data']['date']['readable'].toString(),
                      content['data']['timings']['Midnight'].toString(),
                      content['data']['meta']['timezone'].toString()),

                ],
              );
            } else {
              return new Container();
            }
          });
    }
    else if (connectivity == false) {
      return getNoConnectionWidget();
    }
  }

  Widget getCard(String lead,String updated , String time ,String timezone ) {


//    if(lead == "Sunset"){
//      stateSetter(60.0 , 0.6 , true);
//    }
//    else if(lead == "Isha"){
//      stateSetter(90.0, 0.9, true);
//    }
//    else if(lead == "Midnight"){
//      stateSetter(100.0, 1.0, false);
//    }

    return  SizedBox(
      height: 120.0,
      child:  new Card(
//          margin: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
        child: ListTile(
          leading: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
            child: CircleAvatar(
              maxRadius: 40.0,
              backgroundColor: Colors.white70,
              child: new Text(lead, style: new TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold),),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
            child: new Row(

              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Row(
                  children: <Widget>[
                    Text("$lead  : "),
                    Text( time ,style: new TextStyle(color: Colors.blueAccent), ),
                  ],
                ),


              ],
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Text("$timezone   " + updated),
              ],
            ),
          ),
        ),
      ),

    );

  }

  Future<void> _checkConnectivity() async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // connected  network. now load the data .

      setState(() {
        _connection = true;
      });
//    return updateWidget();

      stateSetter(40.0, 0.4, true);

    } else {
      // not  connected . show a image of network not connected .
      print("no network connection");
      setState(() {
        _connection = false;
      });
      stateSetter(40.0, 0.4, false);
//    return new Text("no connection");
    }

  }

  void stateSetter(double progress, double percent, opac) {

    setState(() {
      this.progress = progress;
      this.percent = percent;
      this.opac = opac;
    });

  }

}




