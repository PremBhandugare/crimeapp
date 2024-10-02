import 'dart:async';

import 'package:flutter/material.dart';

class TimerScr extends StatefulWidget{
  const TimerScr({super.key,required this.onaccideental});
  final void Function() onaccideental ;

  @override
  State<TimerScr> createState() => _TimerScrState();
}

class _TimerScrState extends State<TimerScr> {
  static const maxseconds = 20 ;
  int seconds = 15 ;
  Timer ?timer;

  void startimer(){
     timer = Timer.periodic(
      (Duration(seconds: 1)), 
      (_){
        setState(() {
          if (seconds>0) {
            seconds--;
          }
        });

        if (seconds==0) {
         Navigator.of(context).pop(); 
        }
      }
      );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startimer();

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ACCIDENTAL SHAKE ?',
            style: TextStyle(
              color: Colors.white,
            ),
            ),
          backgroundColor: Colors.red,
        ),
        body: Padding(
            padding: EdgeInsets.all(8),
            child: Center(
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
              //  crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80,),
                  Text(
                    'Was that shake accidental ?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300
                    ),
                    ),
                  const SizedBox(height: 45,),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: seconds/maxseconds,
                          valueColor: AlwaysStoppedAnimation(Colors.red),
                          strokeWidth: 12,
                          
                        ),
                       Center(
                         child: Text(
                          '$seconds',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                          ),
                          ),
                       ),
              
                      ],
                    ),
                  ),
                  const SizedBox(height: 35,),
                  ElevatedButton(
                    onPressed: widget.onaccideental, 
                    child: Text('Yes it was Accidental'),
                    ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}