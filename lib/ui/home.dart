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
        title: new Text("Salah Timings" ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            tooltip: 'share',
            onPressed: ()=> debugPrint('share'),
          ),
          IconButton(
            icon: Icon(Icons.edit),
            tooltip: 'edit',
            onPressed:(){_gotoNextScreen(context);},
          ),

        ],
//        centerTitle: true,

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

  Future _gotoNextScreen(BuildContext context) async {
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

        String timing = result['timing'];
        String hour  = result['hour']+':'+result['minute'];
        print(hour);
        print(timing);

        setValues(timing ,hour );

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

      return new FutureBuilder(
          future: getTimings(),
          builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
            if (snapshot.hasData) {
              Map content = snapshot.data;


              return new Column(
                children: <Widget>[

//                  getProgressCircle(1.0, 100, false),

                  new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: new Text('S', style: new TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[

                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Sehar ", style: new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),),
                              Opacity(opacity: 0.0,
                                  child: Text(" masjid updated on : " +
                                      content['updated'])),
                            ],
                          ),

                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Start : " + content['sehari']),
                              Text("End : " + content['sehari']),
                            ],
                          ),
                        ],
                      ),
                      subtitle: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(content['place']),
                          Text("updated on : " + content['updated']),
                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: new Text('F', style: new TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),),
                      ),
                      title: Column(
                        children: <Widget>[

                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Fajr ", style: new TextStyle(fontSize: 20.0,
                                  fontWeight: FontWeight.bold),),
                              Opacity(opacity: 0.0,
                                  child: Text(" masjid updated on : " +
                                      content['updated'])),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Azaan : " + content['fajr']),
                              Text("Iqamath : " + content['fajr']),
                            ],
                          ),
                        ],
                      ),
                      subtitle: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(content['place']),
                          Text("updated on : " + content['updated']),
                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: new Text('Z', style: new TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),),
                      ),
                      title: Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Zohar ", style: new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),),
                              Opacity(opacity: 0.0,
                                  child: Text(" masjid updated on : " +
                                      content['updated'])),
                            ],
                          ),

                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Azaan : " + content['zohar']),
                              Text("Iqamath : " + content['zohar']),
                            ],
                          ),
                        ],
                      ),
                      subtitle: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(content['place']),
                          Text("updated on : " + content['updated']),
                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: new Text('A', style: new TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),),
                      ),
                      title: Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Asar ", style: new TextStyle(fontSize: 20.0,
                                  fontWeight: FontWeight.bold),),
                              Opacity(opacity: 0.0,
                                  child: Text(" masjid updated on : " +
                                      content['updated'])),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Azaan : " + content['asar']),
                              Text("Iqamath : " + content['asar']),
                            ],
                          ),
                        ],
                      ),
                      subtitle: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(content['place']),
                          Text("updated on : " + content['updated']),
                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: new Text('I', style: new TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),),
                      ),
                      title: Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Iftiyaar ", style: new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),),
                              Opacity(opacity: 0.0,
                                  child: Text(" masjid updated on : " +
                                      content['updated'])),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Start : " + content['iftiyaari']),
                              Text("End : " + content['iftiyaari']),
                            ],
                          ),
                        ],
                      ),
                      subtitle: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(content['place']),
                          Text("updated on : " + content['updated']),

                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: new Text('M', style: new TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),),
                      ),
                      title: Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Magrib ", style: new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold),),
                              Opacity(opacity: 0.0,
                                  child: Text(" masjid updated on : " +
                                      content['updated'])),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Azaan : " + content['magrib']),
                              Text("Iqamath : " + content['magrib']),
                            ],
                          ),
                        ],
                      ),
                      subtitle: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(content['place']),
                          Text("updated on : " + content['updated']),
                        ],
                      ),
                    ),
                  ),

                  new Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: new Text('I', style: new TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold),),
                      ),
                      title: Column(
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Isha ", style: new TextStyle(fontSize: 20.0,
                                  fontWeight: FontWeight.bold),),
                              Opacity(opacity: 0.0,
                                  child: Text(" masjid updated on : " +
                                      content['updated'])),
                            ],
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Text("Azaan : " + content['isha']),
                              Text("Iqamath : " + content['isha']),
                            ],
                          ),
                        ],
                      ),
                      subtitle: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(content['place']),
                          Text("updated on : " + content['updated']),
                        ],
                      ),
                    ),
                  ),

                ],
              );
            } else {
              return new Container();
            }
          });
     return new Text("connected");
    }
    return new Text("no connection");
  }

  void setValues(String timing, String hour) {

      dbReference.update({'$timing':'$hour'});

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

}






