// import 'package:flutter/material.dart';
// import 'package:location/location.dart';

// class  addloc extends StatefulWidget{
//   const addloc({super.key});
//   @override
//   State<addloc> createState() => _addlocState();
// }

// class _addlocState extends State<addloc> {
//   var isloading = false ;
//   void getCurrLoc() async{
//     Location location = Location();

// bool serviceEnabled;
// PermissionStatus permissionGranted;
// LocationData locationData;

// serviceEnabled = await location.serviceEnabled();
// if (!serviceEnabled) {
//   serviceEnabled = await location.requestService();
//   if (!serviceEnabled) {
//     return;
//   }
// }

// permissionGranted = await location.hasPermission();
// if (permissionGranted == PermissionStatus.denied) {
//   permissionGranted = await location.requestPermission();
//   if (permissionGranted != PermissionStatus.granted) {
//     return;
//   }
// }
// setState(() {
//   isloading = true ;
// });
// locationData = await location.getLocation();
// print(locationData.latitude);
// setState(() {
//   isloading = false ;
// });
//   }


//   Widget locContent = const Text('No Location added');
//   @override
//   Widget build(BuildContext context) {
//     if (isloading) {
//       locContent =const CircularProgressIndicator();
//     } else {
//       locContent = Text(
//          'No Location added',
//          style: Theme.of(context).textTheme.titleMedium!
//          .copyWith(
//           color: Theme.of(context).colorScheme.onBackground
//          ),
//          );
      
//     }
//     return Column(
//       children: [
//         Container(
//       decoration: BoxDecoration(
//         border: Border.all(
//           width: 1,
//           color: Theme.of(context).colorScheme.primary
//         )
//       ),
//       height: 200,
//       width: double.infinity,
//       alignment: Alignment.center,
//       child: locContent
//     ),
//     Row(
//       children: [
//         IconButton(onPressed: getCurrLoc, 
//                   icon: const Icon(Icons.share_location)),
//         IconButton(onPressed: (){}, 
//                     icon:const Icon(Icons.map) ),
//       ],
//     )
//       ],
//     );
//   }
// }