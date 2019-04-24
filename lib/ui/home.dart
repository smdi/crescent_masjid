import 'package:connectivity/connectivity.dart';
import 'package:crescent_masjid/util/util.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:advanced_share/advanced_share.dart';
import 'editor.dart';
import 'search.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';

int flag = 0;
Map<dynamic, dynamic> content;


final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<
    RefreshIndicatorState>();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {


  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _bodyController = new TextEditingController();

  AudioPlayer audioPlayer = new AudioPlayer();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var _connection = true,
      opac;
  double percent, progress;


  @override
  void initState()
  {
  // TODO: implement initState
  super.initState();


  WidgetsBinding.instance
      .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show ());

  stateSetter(20.0, 0.2, true);

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
              icon: Icon(Icons.message),
              tooltip: 'message',
              onPressed: () {
                sendMessage();
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              tooltip: 'search',
              onPressed: () {
                _gotoSearch(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.edit),
              tooltip: 'edit',
              onPressed: () {
//                _gotoEditor(context);
                  _showDialog();
              },
            ),

          ],

        ),

        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: _checkConnectivity,
          child: new ListView(
            children: <Widget>[

              getProgressCircle(percent, progress, opac),
              updateWidget(_connection),

            ],
          ),
        ),
      floatingActionButton: new FloatingActionButton(
          backgroundColor: Colors.blueAccent.shade400,
          onPressed: ()=> {_share()} ,
          child: Icon(Icons.share )
        ),
    );
  }

  Future _gotoSearch(BuildContext context) async {
    Navigator.of(context).push(
        new MaterialPageRoute<Map>(
            builder: (BuildContext context) {
              return new Search();
            })
    );
  }

  Future _gotoEditor(BuildContext context) async {
    Map result = await Navigator.of(context).push(
        new MaterialPageRoute<Map>(
            builder: (BuildContext context) {
              return new Editor();
            })
    );
    if (result != null && result.containsKey('hour')) {
      if (_connection) {
        flag = 0;
        print(result['hour']);
        print(result['minute']);
        print(result['timing']);
        print(result['hoursEndVal']);
        print(result['minuteEndVal']);

        String timing = result['timing'];

        updateTimings(timing, result);
      }
    }
  }

  Future<Map> getTimings() async {
    Map<dynamic, dynamic> data;

    stateSetter(60.0, 0.6, true);
    stateSetter(70.0, 0.7, true);


    dbReference = database.reference().child("timings");

    if (flag == 0) {
      await dbReference.once().then((DataSnapshot snapshot) {
        data = snapshot.value;
        flag = 1;
        content = data;
      });
      print("inside if");
      stateSetter(80.0, 0.8, false);
      return content;
    }
    else {
      print("inside else cached data");
      return content;
    }

  }

  Widget updateWidget(bool connection) {
    if (connection) {
      print("connection");
//      stateSetter(100.0, 1.0, false);

      return
        new FutureBuilder(
            future: getTimings(),
            builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
              if (snapshot.hasData) {
                Map content = snapshot.data;
                print("content");
                print(content);
                return new Column(
                  children: <Widget>[

                    getHeading("Salah Timings"),

                    getCardSalah("Fajr", content['updated'], content['fajr'], content['fajr_iqamah']),

                    getCardSalah("Zohar", content['updated'], content['zohar'], content['zohar_iqamah']),

                    getCardSalah("Jum'ah", content['updated'], content['jumah'], content['jumah_iqamah']),

                    getCardSalah("Asar", content['updated'], content['asar'], content['asar_iqamah']),

                    getCardSalah("Magrib", content['updated'], content['magrib'], content['magrib_iqamah']),

                    getCardSalah("Isha", content['updated'], content['isha'], content['isha_iqamah']),

                    getHeading("Sunrise & Sunset"),

                    getCardSun("Sunrise", content['updated'], content['sunrise']),

                    getCardSun("Sunset", content['updated'], content['sunset']),

                    getHeading("Sehar , Iftiyar & Taraweeh"),

                    getCardSun("Sehar", content['updated'], content['sehari']),

                    getCardSun("Iftiyar", content['updated'], content['iftiyaari']),

                    getCardSun("Taraweeh", content['updated'], content['taraweeh']),

                  ],
                );
              } else {
                return new Container();
              }
            });
    }
    else if (connection == false) {
      return getNoConnectionWidget();
    }
  }

  void setOneValues(String timing, String hour) {
    String date = getDate();
    print("Date");
    print(date);
    dbReference.update({'$timing': '$hour'});
    dbReference.update({'updated': '$date'});
  }

  void setTwoValues(String timing, String hour, String hourLast) {
    String date = getDate();
    dbReference.update({'$timing': '$hour'});
    dbReference.update({'$timing' + '_iqamah': '$hourLast'});
    dbReference.update({'updated': '$date'});
  }

  void firebaseListener() {
    messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        await audioPlayer.play('audio/chime.mp3', isLocal: true);
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        await audioPlayer.play('audio/chime.mp3', isLocal: true);
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        await audioPlayer.play('audio/chime.mp3', isLocal: true);
        print('on launch $message');
      },
    );
  }

  void _setSubscribed(int val) async {
    SharedPreferences subScribed = await SharedPreferences.getInstance();
    await subScribed.setInt("$sub", val);
  }

  Future<int> getSubscribed() async {
    SharedPreferences subScribed = await SharedPreferences.getInstance();
    return subScribed.getInt("$sub");
  }

  void _loadData() async {
    //subscribe to topic
    int check = await getSubscribed();
    print(check);
    if (check == null) {
      print("subscribing");
      messaging.getToken().then((token) {
        print(token);
        //send to server
        tokenToServer(token);
      });
      messaging.subscribeToTopic("timings");
      print("subscribed");
      _setSubscribed(1);
    } else {
      print("subscribed");
    }
  }

  void tokenToServer(String token) async {
    String apiUrl = "https://crescent-masjid-timings.herokuapp.com/register?token=$token";
    http.Response response = await http.get(apiUrl);
    print("getting response");
    print(response.body);
    // snackbar for success registration
  }

  void updateUsers(String url) async {
    String apiUrl = url;
    http.Response response = await http.get(apiUrl);
    print("getting response");
    print(response.body);
    // snackbar for success registration
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      // connected  network. now load the data .

      _loadData();
      firebaseListener();
      dbReference = database.reference().child("timings");
      print("connected to network");


      setState(() {
        _connection = true;
      });


      if (flag == 1) {
        stateSetter(50.0, 0.5, false);
      }
      else {
        stateSetter(50.0, 0.5, true);
      }
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

  Widget getCardSalah(String lead, String updated, String azaan,
      String iqamah) {
    return SizedBox(

      height: 120.0,
      child: new Card(
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
                    Text(
                      azaan, style: new TextStyle(color: Colors.blueAccent),),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                  child: Row(
                    children: <Widget>[
                      Text("Iqamah : "),
                      Text(iqamah,
                        style: new TextStyle(color: Colors.blueAccent),),
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

  Widget getCard(String lead, String updated, String azaan, String iqamah) {
    return SizedBox(
      height: 120.0,
      child: new Card(
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
                    Text(
                      azaan, style: new TextStyle(color: Colors.blueAccent),),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 0, 0, 0),
                  child: Row(
                    children: <Widget>[
                      Text("   End : "),
                      Text(iqamah,
                        style: new TextStyle(color: Colors.blueAccent),),
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

  Widget getCardSun(String lead, String updated, String time) {
    return SizedBox(
      height: 120.0,
      child: new Card(
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
                    Text(time, style: new TextStyle(color: Colors.blueAccent),),
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
      child: new Text("$s", style: new TextStyle(color: Colors.blueAccent),),
    ));
  }

  void updateTimings(String value, Map result) {
    int flag = 0;
    for (var i = 0; i < oneList.length; i++) {
      if (value == oneList[i]) {
        print("one time");
        flag = 1;
      }
    }
    if (flag == 1) {
      String timing = result['timing'];
      String hour = result['hour'] + ':' + result['minute'];

      print(hour);
      print(timing);

      setOneValues(timing, hour);
      updateUsers(
          "https://crescent-masjid-timings.herokuapp.com/notify?head=$timing timings has updated&contain=$timing - $hour");
    }
    else {
      String timing = result['timing'];
      String hour = result['hour'] + ':' + result['minute'];
      String hourLast = result['hoursEndVal'] + ':' + result['minuteEndVal'];

      print(hour);
      print(timing);
      print(hourLast);

      setTwoValues(timing, hour, hourLast);
      updateUsers(
          "https://crescent-masjid-timings.herokuapp.com/notify?head=$timing timings has updated&contain=$timing - $hour -- $hourLast");
    }
  }

  String getDate() {
    var now = new DateTime.now();
    print(now);
    if (now.day < 10 && now.month < 10) {
      return "0${now.day}-0${now.month}-${now.year}";
    }
    else if (now.day < 10 && now.month >= 10) {
      return "0${now.day}-${now.month}-${now.year}";
    }
    else if (now.day >= 10 && now.month < 10) {
      return "${now.day}-0${now.month}-${now.year}";
    }
    else {
      return "${now.day}-${now.month}-${now.year}";
    }
  }

  void stateSetter(double progress, double percent, opac) {
    setState(() {
      this.progress = progress;
      this.percent = percent;
      this.opac = opac;
    });
  }

  void _showDialog(){

    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(

            title: new Text("Admin Acess",style: new TextStyle(color: Colors.blueAccent),),
            content:  Container(
              width: 260.0,
              height: 70.0,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFFFFFF),
                borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    labelText: 'Password',
                    hintText: '********',
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {

                  _passwordController.text = "";
                  Navigator.of(context).pop();
                },
              ),

              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {

                  if(_passwordController.text.toString() == password1 ||
                      _passwordController.text.toString() == password2 || _passwordController.text.toString() ==password3 ){

                      _passwordController.text = "";
                      getToast(Colors.blueAccent.shade400 ,"       Edit Timings       ");
                      Navigator.of(context).pop();
                      _gotoEditor(context);
                  }
                  else {
                    //show snackbar message that auth failed
                    _passwordController.text = "";
                    getToast(Colors.red.shade700 ,"Authentication Failed");
                    Navigator.of(context).pop();
                  }

                },
              ),


            ],
          );
    });

  }

  void getToast(Color shade700, String s) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: shade700,
        textColor: Colors.white,
        fontSize: 16.0,
    );
  }

  void sendMessage() {
    showDialog(context: context,
        builder: (BuildContext context){
          return AlertDialog(

            title: new Text("Convey message to all" ,style: new TextStyle(color: Colors.blueAccent),),
            content: Container(
              width: 260.0,
              height: 70.0,
              decoration: new BoxDecoration(
                shape: BoxShape.rectangle,
                color: const Color(0xFFFFFF),
                borderRadius: new BorderRadius.all(new Radius.circular(32.0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TextField(
                  controller: _bodyController,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                    labelText: 'Message',
                    hintText: 'Come to masjid for gathering.',
                  ),
                ),
              ),
            ),

            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {


                  _bodyController.text = "";
                  Navigator.of(context).pop();
                },
              ),

              new FlatButton(
                child: new Text("Ok"),
                onPressed: () {


                  print('body');
                  if( _bodyController.text.isNotEmpty ){

                    print("inside if body");
                    String body = _bodyController.text.isEmpty ? "Come to masjid for gathering" : _bodyController.text ;

                    //send message to users
                    updateUsers(
                        "https://crescent-masjid-timings.herokuapp.com/notify?head=crescent majid"
                            "&contain=${body}");
                    getToast(Colors.blueAccent.shade400 ,"       Sending message       ");
                    _bodyController.text = "";
                    Navigator.of(context).pop();

                  }
                  else {
                    //show snackbar message that auth failed

                    _bodyController.text = "";
                    getToast(Colors.red.shade700 ,"Enter valid details");
                    Navigator.of(context).pop();
                  }

                },
              ),


            ],
          );
        });
  }

  void _share() {
    AdvancedShare.generic(
      msg: "$app_name \n\n https://play.google.com/store/apps/details?id=com.zulfiqar.crescent_masjid&hl=en",
      title: "$app_name link",
    ).then((response){
      print(response);
    });
  }

}






