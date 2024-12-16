import 'dart:async';

import 'package:background_sms/background_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crimeapp/main.dart';
import 'package:crimeapp/noti.dart';
import 'package:crimeapp/screens/NewsScr.dart';
import 'package:crimeapp/screens/SplashScr.dart';
import 'package:crimeapp/screens/chatScr.dart';
import 'package:crimeapp/screens/drawScr.dart';
import 'package:crimeapp/screens/home.dart';
import 'package:crimeapp/screens/loginscr.dart';
import 'package:crimeapp/screens/timer.dart';
import 'package:crimeapp/structure/crimedata.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';

enum smsStatus{sent,failed}

class Tabs extends StatefulWidget{
  const Tabs({super.key,required this.flnp});
  final FlutterLocalNotificationsPlugin flnp ;
  
  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  Position? currPos;
  Position? currAdd;
  int currInd = 1 ;
  void selTab(int index){
    setState(() {
      currInd = index;
    });
  }

  getPerm() async => await [Permission.sms].request();
  isPermGrant() async => await Permission.sms.status.isGranted;
  sendsms(String Numb,String msg,{int? simslot})async{
    await BackgroundSms.sendMessage(
      phoneNumber: Numb, 
      message: msg
      ).then((SmsStatus status){
        if (status==smsStatus.sent) {
          Fluttertoast.showToast(msg: "sent");
        } else {
          Fluttertoast.showToast(msg: "failed");
        }
      });
  }
  getLoc() async {
  final permissionStatus = await Geolocator.checkPermission();
  if (permissionStatus == LocationPermission.denied) {
    // Request permission if it's denied but not forever
    final newStatus = await Geolocator.requestPermission();
    if (newStatus == LocationPermission.denied || newStatus == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permission is denied. Please enable it in settings.");
    } else {
      // Permission granted
      _fetchLocation();
    }
  } else if (permissionStatus == LocationPermission.deniedForever) {
    // Location permission denied forever
    Fluttertoast.showToast(msg: "Location permission is permanently denied. Please enable it in app settings.");
    // Optionally, you can open app settings
    await openAppSettings();
  } else {
    // Permission granted
    _fetchLocation();
  }
}
List<Map<String, dynamic>> RcrimeData=[];
List<dynamic>? emergencyContacts;
Future<void> _fetchEmergencyContacts() async {
    final user = FirebaseAuth.instance.currentUser;
    final repdoc = await FirebaseFirestore.instance.collection("report").get();
    setState(() {
      RcrimeData = repdoc.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
      

    if (user != null) {
      // Fetch user document from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          emergencyContacts = data['emergencyNumber'] ?? [];// Fetch emergency contacts list
        });
        Fluttertoast.showToast(msg: 'Data Fetched');
      }
    }
  }
void _fetchLocation() async {
  try {
    final Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true,
    );
    setState(() {
      currPos = pos;
    });
  } catch (e) {
    Fluttertoast.showToast(msg: e.toString());
  }
}


  
  ShakeDetector? shakeDetector;
  Timer? smsTimer;
 void _showConfirmationDialog() {
    
    smsTimer?.cancel();
    smsTimer = Timer(Duration(seconds: 20), () async{
      
      String msgbody ='BACHAO BACHAOOO BACHAOOOOO\nLocation : https://www.google.com/maps?q=${currPos!.latitude},${currPos!.longitude}';
        if (await isPermGrant()) {
          for (var i = 0; i < emergencyContacts!.length; i++) {
            sendsms(emergencyContacts![i], msgbody,simslot: 1);  
          }
          Fluttertoast.showToast(msg: 'Please wait for 60 seconds to use the shake again');
        }
        else{
          Fluttertoast.showToast(msg: 'SMS not sent');
        }
             //Navigator.of(context).pop();   

    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:(ctx)=>
            TimerScr(
            onaccideental: (){
              smsTimer!.cancel();
              Navigator.of(context).pop();
            }
            ) )
    );
  }
  Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    requestNotificationPermission();
    Noti.initialise(widget.flnp);
    _fetchEmergencyContacts();
    getPerm();
    getLoc();
    shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: () async {
        _fetchEmergencyContacts();
        getLoc();
      _fetchEmergencyContacts();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shake!'),
          ),
        );
        if (shakeDetector!.mShakeCount==2) {
        Noti.showNoti(fln: widget.flnp).then((_) {
            Fluttertoast.showToast(msg: "Notification Triggered");
           }).catchError((e) {
            print("Notification Failed: $e");
        });

        _showConfirmationDialog();
          
        }

      },
      minimumShakeCount: 2,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 20000,
      shakeThresholdGravity: 2.7,
    );
     
  }  
 
  

   @override
  Widget build(BuildContext context) {
    String actText = 'Home';
    Widget actScr =Home(crimeData: crimeData,flnp: widget.flnp,) ;
    if (currInd==1) {
      actScr =  Home(crimeData: crimeData,flnp: widget.flnp,);
      actText = 'News';
    }
    if (currInd==0) {
      actScr =  SplashScr(crimeData:crimeData,);
      actText = 'Map';
    }
    if (currInd==2) {
      actScr =   const AddReport();
      actText = 'Updates';
    }
    if (currInd==3) {
      actScr = ChatScreen();
      actText = 'Live Chat';
    }
    Future<bool> _onWillPop() async {
    if (currInd != 1) {
      setState(() {
        currInd = 1; 
      });
      return false; 
    } else {
      return true; 
    }
  }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: Text(
            actText,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold
            ),
            ),
           actions: [
             StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
      
          if (snapshot.hasData) {
            return TextButton(
              onPressed: ()async{
                 showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to logout?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                              ),
                              TextButton(
                                child: const Text('Yes'),
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                              ),
                            ],
                          );
                        },
                      );
              }, 
              child: const Text(
                 'Signout',
                 style: TextStyle(color: Colors.white),
                 )
              );
          }
      
          return TextButton(
            onPressed: (){
              Navigator.of(context).push(
                ModalBottomSheetRoute(
                  builder: (ctx){return const LoginScr();}, 
                  isScrollControlled: false
                  ) 
                );
            }, 
            child: const Text(
              'Signin',
              style: TextStyle(color: Colors.white),
            )
            );
        },
      ),
      ], 
          backgroundColor: Colors.red,
        ),
      //  drawer: Drawerr(changescr: changescr),
        drawer: Drawer(
          child:DrawerScreen()
        ),
        body:actScr,
        floatingActionButton: FloatingActionButton(          
              backgroundColor: Colors.white,
              onPressed: (){},
              child: InkWell(
                onTap: ()async{
                  _fetchEmergencyContacts();
                  String msgbody ='BACHAO BACHAOOO BACHAOOOOO\nLocation : https://www.google.com/maps?q=${currPos!.latitude},${currPos!.longitude}';
          if (await isPermGrant()) {
             for (var i = 0; i < emergencyContacts!.length; i++) {
              sendsms(emergencyContacts![i], msgbody,simslot: 1);  
            }
           
            
          }
          else{
            Fluttertoast.showToast(msg: 'SMS not sent');
          }
                },
                child: CircleAvatar(
                  child: Text('S.O.S',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                  backgroundColor: Colors.white,
                ),
              ),
              ), 
        floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,    
          
          
        
        bottomNavigationBar: BottomNavigationBar(
          
          onTap: (index) {
            selTab(index);
          },
          currentIndex:currInd ,
          fixedColor:Colors.red,
          unselectedItemColor: Colors.grey,
          items:const [
            BottomNavigationBarItem(icon: Icon(Icons.map),label: 'Map'),
            BottomNavigationBarItem(icon:Icon(Icons.home),label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.report),label: 'Report'),
            BottomNavigationBarItem(icon: Icon(Icons.chat),label: 'Live Chat'),
      
          ],
        ),
      ),
    );
  }
}