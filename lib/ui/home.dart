import 'dart:convert';
import 'package:crescent_masjid/util/util.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:crescent_masjid/models/model.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editor.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'search.dart';


var _connection = false , opac;
double percent , progress ;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());

    setState(() {
      progress = 40.0;
      percent = 0.4;
      opac = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.grey.shade200,

        appBar: new AppBar(
        backgroundColor: Colors.lightBlue,
        title: new Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'search',
            onPressed: (){_gotoSearch(context);},
          ),
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'edit',
            onPressed:(){_gotoEditor(context);},
          ),

        ],
//

      leading:IconButton(
        icon: Icon(Icons.menu),
        tooltip: 'menu',
        onPressed:()=>debugPrint('menu'),
      ),
      ),

      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _checkConnectivity,
        child: new ListView(
          children: <Widget>[

            getProgressCircle(percent,progress,opac),
            updateWidget(_connection),

          ],
        ),
      )
    );
  }

  Future _gotoSearch(BuildContext context) async {

    Map result  = await Navigator.of(context).push(
        new MaterialPageRoute<Map>(
            builder: (BuildContext context){
              return new Search();
            })
    );
    if (result!= null && result.containsKey('city')){

      print(result['city']);
      print(result['country']);

    }
    
  }
  
  Future _gotoEditor(BuildContext context) async {
    Map result  = await Navigator.of(context).push(
        new MaterialPageRoute<Map>(
            builder: (BuildContext context){
              return new Editor();
            })
    );
    if (result!= null && result.containsKey('hour')){


        print(result['hour']);
        print(result['minute']);
        print(result['timing']);
        print(result['hoursEndVal']);
        print(result['minuteEndVal']);

        String timing = result['timing'];

        updateTimings(timing ,result);

    }


  }

  Future<Map> getTimings() async{

    Map<dynamic , dynamic> data;

    dbReference =  database.reference().child("timings");

    await dbReference.once().then((DataSnapshot snapshot){

      data = snapshot.value;

    });

    setState(() {
      progress = 100.0;
      percent = 1.0;
      opac= false;
    });

      return data;
  }

  Widget updateWidget(bool connection) {

    if(connection) {

      setState(() {
        progress = 70.0;
        percent = 0.7;
        opac = true;
      });

      return new FutureBuilder(
          future: getTimings(),
          builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
            if (snapshot.hasData) {
              Map content = snapshot.data;

              return new Column(
                children: <Widget>[

                  getHeading("Salah Timings"),

                  getCardSalah("Fajr",content['updated'],content['fajr'], content['fajr_iqamah']),

                  getCardSalah("Zohar",content['updated'],content['zohar'], content['zohar_iqamah']),

                  getCardSalah("Jum'ah",content['updated'],content['jumah'], content['jumah_iqamah']),

                  getCardSalah("Asar",content['updated'],content['asar'], content['asar_iqamah']),

                  getCardSalah("Magrib",content['updated'],content['magrib'], content['magrib_iqamah']),

                  getCardSalah("Isha",content['updated'],content['isha'], content['isha_iqamah']),

                  getHeading("Sehar , Iftiyar & Taraweeh"),

                  getCardSun("Sehar",content['updated'],content['sehari']),

                  getCardSun("Iftiyar",content['updated'],content['iftiyaari']),

                  getCardSun("Taraweeh",content['updated'],content['taraweeh']),

                  getHeading("Sunrise & Sunset"),

                  getCardSun("Sunrise",content['updated'],content['sunrise']),

                  getCardSun("Sunset",content['updated'],content['sunset']),

                ],
              );
            } else {
              return new Container();
            }
          });

    }
    return new Text("no connection");
  }

  void setOneValues(String timing, String hour) {

      String date = getDate();
      dbReference.update({'$timing':'$hour'});
      dbReference.update({'updated':'$date'});

  }

  void setTwoValues(String timing, String hour, String hourLast) {

    String date = getDate();
    dbReference.update({'$timing':'$hour'});
    dbReference.update({'$timing'+'_iqamah':'$hourLast'});
    dbReference.update({'updated':'$date'});

  }

  void firebaseListener() {


    messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void _setSubscribed(int val) async{

    SharedPreferences subScribed = await SharedPreferences.getInstance();
    await subScribed.setInt("$sub", val);

  }

  Future<int> getSubscribed() async{

    SharedPreferences subScribed = await SharedPreferences.getInstance();
    return  subScribed.getInt("$sub") ;
  }

  void _loadData() async {
    //subscribe to topic
    int check  = await getSubscribed();
    print(check);
    if (check== null){
      print("subscribing");
      messaging.getToken().then((token){
        print(token);
        //send to server
        tokenToServer(token);
      });
      messaging.subscribeToTopic("timings");
      print("subscribed");
      _setSubscribed(1);
    }else{
      print("subscribed");

    }
  }

  void tokenToServer(String token) async{
    String apiUrl = "https://crescent-masjid-timings.herokuapp.com/register?token=$token";
    http.Response response = await http.get(apiUrl);
    print("getting response");
    print(response.body);
    // snackbar for success registration
  }

  void updateUsers(String  url) async{
    String apiUrl = url;
    http.Response response = await http.get(apiUrl);
    print("getting response");
    print(response.body);
    // snackbar for success registration
  }

  Future<void> _checkConnectivity() async {

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // connected  network. now load the data .

      _loadData();
      firebaseListener();
      dbReference =  database.reference().child("timings");
      print("connected to network");

//      _connection = true;

      setState(() {
        _connection = true;
      });
//    return updateWidget();

      setState(() {
        progress = 40.0;
        percent = 0.4;
        opac = true;
      });

    } else {
      // not  connected . show a image of network not connected .
      print("no network connection");
          setState(() {
            _connection = false;
          });
      setState(() {
        progress = 40.0;
        percent = 0.4;
        opac = false;
      });
//    return new Text("no connection");
    }

  }

  Widget getCardSalah(String lead,String updated , String azaan ,String iqamah ) {

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
                    Text("Azaan  : "),
                    Text( azaan ,style: new TextStyle(color: Colors.blueAccent), ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0 ,0,0,0),
                  child: Row(
                    children: <Widget>[
                      Text("Iqamah : "),
                      Text(iqamah ,style: new TextStyle(color: Colors.blueAccent),),
                    ],
                  ),
                ),
              ],
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text("Last updated on : " + updated),
              ],
            ),
          ),
        ),
      ),

    );

  }

  Widget getCard(String lead,String updated , String azaan ,String iqamah ) {

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
                    Text("Start  : "),
                    Text( azaan ,style: new TextStyle(color: Colors.blueAccent), ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0 ,0,0,0),
                  child: Row(
                    children: <Widget>[
                      Text("   End : "),
                      Text(iqamah ,style: new TextStyle(color: Colors.blueAccent),),
                    ],
                  ),
                ),
              ],
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                Text("Last updated on : " + updated),
              ],
            ),
          ),
        ),
      ),

    );

  }

  Widget getCardSun(String lead,String updated , String time ) {

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

                Text("Last updated on : " + updated),
              ],
            ),
          ),
        ),
      ),

    );

  }

  Widget getHeading(String s) {

    return Center(child: Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
      child: new Text("$s",style: new TextStyle(color: Colors.blueAccent),),
    ));
  }

  void updateTimings(String value, Map result) {

    int flag = 0;
    for(var i = 0;i<oneList.length;i++){
      if(value == oneList[i]){
        print("one time");
        flag = 1;
      }
    }
    if(flag == 1){
      String timing = result['timing'];
      String hour  = result['hour']+':'+result['minute'];

      print(hour);
      print(timing);

      setOneValues(timing ,hour );
      updateUsers("https://crescent-masjid-timings.herokuapp.com/notify?head=$timing timings has updated&contain=$timing - $hour");
    }
    else {
      String timing = result['timing'];
      String hour  = result['hour']+':'+result['minute'];
      String hourLast  = result['hoursEndVal']+':'+result['minuteEndVal'];

      print(hour);
      print(timing);
      print(hourLast);
      
      setTwoValues(timing ,hour , hourLast );
      updateUsers("https://crescent-masjid-timings.herokuapp.com/notify?head=$timing timings has updated&contain=$timing - $hour -- $hourLast");
    }
  }

  String getDate() {
    var now = new DateTime.now();
    print(now);
    if(now.day < 10){
      if(now.month < 10){
        return "0${now.day}-0${now.month}-${now.year}";
      }
      else{
        return "0${now.day}-${now.month}-${now.year}";
      }
    }
  }

}






