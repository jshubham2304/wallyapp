import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wallyapp/Page/HomePage.dart';
import 'package:wallyapp/Page/SignInScreen.dart';
import 'package:wallyapp/config.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      fontFamily: "productsans"

    ),
   home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

 FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
  
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        String title = message["notification"]["title"]??"";
        String body = message["notification"]["body"]??"";
        
        _showDialogNotify(title: title,body: body,);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        
        String title = message["notification"]["title"]??"";
        
        String body = message["notification"]["body"]??"";
        _showDialogNotify(title: title,body: body);
        },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        
        String title = message["notification"]["title"]??"";
        
        String body = message["notification"]["body"]??"";
        _showDialogNotify(title: title,body: body);
        },
    );
    firebaseMessaging.subscribeToTopic("promotions");
    super.initState();
  }
  void _showDialogNotify({String title,String body,String icon})
  {
      showDialog(context: context,
      builder: (ctx){
        return  AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(title),
          content: Text(body),
           
          actions: <Widget>[
            RaisedButton(onPressed: (){Navigator.of(context).pop();},child: Text("Dismiss"),)
          ],
        );
      });
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: auth.onAuthStateChanged,
      builder: (ctx,AsyncSnapshot<FirebaseUser>snapshot)  {
          if(snapshot.hasData){
            FirebaseUser user = snapshot.data;
            if(user!= null)
            {
              return HomePageScreen();
            }
            else{
              return SignInScreen();
            }
           }
            return SignInScreen();
          
      },
      
    );
  }
  Future _showNotificationWithDefaultSound() async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id', 'your channel name', 'your channel description',
      importance: Importance.Max, priority: Priority.High);
  var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    'New Post',
    'How to Show Notification in Flutter',
    platformChannelSpecifics,
    payload: 'Default_Sound',
  );
}
}