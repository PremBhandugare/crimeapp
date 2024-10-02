import 'dart:async';

import 'package:background_sms/background_sms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crimeapp/main.dart';
import 'package:crimeapp/noti.dart';
import 'package:crimeapp/screens/NewsScr.dart';
import 'package:crimeapp/screens/SplashScr.dart';
import 'package:crimeapp/screens/drawScr.dart';
import 'package:crimeapp/screens/home.dart';
import 'package:crimeapp/screens/loginscr.dart';
import 'package:crimeapp/screens/timer.dart';
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

  // getLoc()async{
  //   final permiss = await Geolocator.checkPermission();
  //   if (permiss==LocationPermission.deniedForever) {
  //     Fluttertoast.showToast(msg: "Denied perm");
  //   }

  //   Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //     forceAndroidLocationManager: true
  //   ).then((Position pos){
  //     setState(() {
  //       currPos = pos;
  //     });
  //   }).catchError((e){
  //     Fluttertoast.showToast(msg: e.toString());
  //   });
  // }
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


  // void changescr() async { 
  //   Navigator.of(context).pop();
  //     await Navigator.of(context).push<Map<Filter,bool>>(
  //     MaterialPageRoute(builder: (ctx){
  //       return const FltrScr();}
  //       ),
  //   );
    
    
  // }
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
    final List<Map<String, dynamic>> crimeData =  [
  {
    "id": 1,
    "title": "Robbery in Mumbai",
    "location": "Mumbai, Maharashtra",
    "description": "A robbery occurred at a jewelry store in Mumbai. The suspects stole valuable items and fled the scene.",
    "imageUrl": "https://images.pexels.com/photos/6266769/pexels-photo-6266769.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    'Latitude': 19.0760,
    'Longitude': 72.8777,
    "date": "2024-03-12"
  },
  {
    "id": 2,
    "title": "Vehicle Theft in Delhi",
    "location": "Delhi",
    "description": "A vehicle was stolen from the parking lot of a residential complex in Delhi. The vehicle was later recovered abandoned.",
    "imageUrl": "https://media.istockphoto.com/id/1205468676/photo/man-stealing-a-car.jpg?s=612x612&w=0&k=20&c=C6fZFSvzL8mQO38LNRrj7Qr5_zQ8vIY8DG4aj_qZ9Ws=",
    'Latitude': 28.7041,
    'Longitude': 77.1025,
    "date": "2024-05-08"
  },
  {
    "id": 3,
    "title": "Assault Case in Bangalore",
    "location": "Bangalore, Karnataka",
    "description": "An assault case was reported in a park in Bangalore. The victim suffered injuries and the police are investigating.",
    "imageUrl": "https://media.istockphoto.com/id/1332523279/photo/domestic-violence-mans-clenched-fist.jpg?s=612x612&w=0&k=20&c=hp_eahMcHd1r6sjxc7ytFHVi2kQ5toPEJl5NAeyjvHw=",
    'Latitude': 12.9716,
    'Longitude': 77.5946,
    "date": "2024-01-22"
  },
  {
    "id": 4,
    "title": "Burglary in Chennai",
    "location": "Chennai, Tamil Nadu",
    "description": "Burglars broke into a house in Chennai and stole electronics and cash. The investigation is ongoing.",
    "imageUrl": "https://media.istockphoto.com/id/1335159036/photo/bandit-in-balaclava-holding-a-crowbar-to-break-a-glass-window.jpg?s=612x612&w=0&k=20&c=7aBBpHJmrEw2CHPOgPFOW77KXTV3kMROlXWooyfYGn0=",
    'Latitude': 13.0827,
    'Longitude': 80.2707,
    "date": "2024-07-14"
  },
  {
    "id": 5,
    "title": "Cybercrime Incident in Hyderabad",
    "location": "Hyderabad, Telangana",
    "description": "A cybercrime incident involving fraudulent transactions was reported in Hyderabad. Authorities are working to trace the perpetrators.",
    "imageUrl": "https://media.istockphoto.com/id/1144604245/photo/a-computer-system-hacked-warning.jpg?s=612x612&w=0&k=20&c=U45FHOm5rflXIRqmYByxlQANtdtycEdFZz2Vp5dgI8E=",
    'Latitude': 17.3850,
    'Longitude': 78.4867,
    "date": "2024-04-20"
  },
  {
    "id": 6,
    "title": "Drug Bust in Kolkata",
    "location": "Kolkata, West Bengal",
    "description": "A major drug bust took place in Kolkata, with several arrests made. Drugs and paraphernalia were seized.",
    "imageUrl": "https://media.istockphoto.com/id/917333680/photo/addict-at-the-table-pulls-his-hand-to-the-syringe-with-the-dose.jpg?s=612x612&w=0&k=20&c=YpRBhsF_1solidKOXZc73gdHao51e-w3Zpxvb9dAku8=",
    'Latitude': 22.5726,
    'Longitude': 88.3639,
    "date": "2024-09-01"
  },
  {
    "id": 7,
    "title": "Kidnapping Case in Pune",
    "location": "Pune, Maharashtra",
    "description": "A kidnapping case was reported in Pune. The victim was rescued and the suspects are in custody.",
    "imageUrl": "https://media.istockphoto.com/id/1359349255/vector/kidnapped-girl-criminal-scene-illustration-vector.jpg?s=612x612&w=0&k=20&c=u8Z6Dw6J7qiQot6c0t5tOhUVrNUdPIq49PVSNyp6IwM=",
    'Latitude': 18.5204,
    'Longitude': 73.8567,
    "date": "2024-06-25"
  },
  {
    "id": 8,
    "title": "Domestic Violence Incident in Jaipur",
    "location": "Jaipur, Rajasthan",
    "description": "A domestic violence incident was reported in Jaipur. The victim received medical attention and the authorities are investigating.",
    "imageUrl": "https://media.istockphoto.com/id/1369137588/photo/domestic-violence-african-american-man-threatening-wife-and-daughter-with-his-fist.jpg?s=612x612&w=0&k=20&c=tG1TqO7Ww5XPl75s5GrFR4LOSoqJMotcJw5vDgM-usY=",
    'Latitude': 26.9124,
    'Longitude': 75.7873,
    "date": "2024-10-10"
  },
  {
    "id": 9,
    "title": "Homicide in Surat",
    "location": "Surat, Gujarat",
    "description": "A homicide occurred in Surat. The victim was found dead, and the police are working on solving the case.",
    "imageUrl": "https://media.istockphoto.com/id/185305538/photo/killing-scene.jpg?s=612x612&w=0&k=20&c=c0Qki6Zhm5NerzY7IOFHuIclQn9cUV-w6M1jjUAwZmg=",
    'Latitude': 21.1702,
    'Longitude': 72.8311,
    "date": "2024-08-30"
  },
  {
    "id": 10,
    "title": "Robbery Attempt in Ahmedabad",
    "location": "Ahmedabad, Gujarat",
    "description": "An attempted robbery was thwarted in Ahmedabad. The suspects were apprehended before they could escape.",
    "imageUrl": "https://media.istockphoto.com/id/838523142/photo/pickpocket.jpg?s=612x612&w=0&k=20&c=OmXthJLGjCSaavmICYSQeFTv8LOxAEhN4jtMilYB9tU=",
    'Latitude': 23.0225,
    'Longitude': 72.5714,
    "date": "2024-11-05"
  }
];
    String actText = 'Home';
    Widget actScr =Home(crimeData: crimeData,) ;
    if (currInd==1) {
      actScr =  Home(crimeData: crimeData,);
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
    Future<bool> _onWillPop() async {
    if (currInd != 1) {
      setState(() {
        currInd = 1; // Go back to Home screen
      });
      return false; // Prevent default back button behavior
    } else {
      return true; // Allow the default back button behavior
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
      
            
            // IconButton(
            //   onPressed:(){
            //     Navigator.of(context).push(
            //     ModalBottomSheetRoute(
            //       builder: (ctx){return const LoginScr();}, 
            //       isScrollControlled: true
            //       ) 
            //     );
            //   }, 
            //   icon:const Icon(Icons.login,color: Colors.white,))
      
           ], 
          backgroundColor: Colors.red,
        ),
      //  drawer: Drawerr(changescr: changescr),
        drawer: Drawer(
          child:DrawerScreen()
        ),
        body:actScr,
        floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: (){
                //NotifyAuthorities();
                },
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
                  child: Text('S.O.S',style: TextStyle(color: Colors.white),),
                  backgroundColor: Colors.red,
                ),
              ),
              ), 
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,    
          
          
        
        bottomNavigationBar: BottomNavigationBar(
          
          onTap: (index) {
            selTab(index);
          },
          currentIndex:currInd ,
          fixedColor:Colors.red,
          items:const [
            BottomNavigationBarItem(icon: Icon(Icons.map),label: 'Map'),
            BottomNavigationBarItem(icon:Icon(Icons.home),label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.report),label: 'Report'),
      
          ],
        ),
      ),
    );
  }
}