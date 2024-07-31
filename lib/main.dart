import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolate/isolate_location_update.dart';
import 'dart:developer' as dev;

import 'package:flutter_isolate/isolate_read_file.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Update Isoloate Demo', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override 
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  IsolateReadFile isolateReadFile = IsolateReadFile();
  IsolateLocationUpdate isolateLocationUpdate = IsolateLocationUpdate();
  double lat=0.0;
  double long=0.0;
  String data=" Empty ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[


            // loading 

           
           const CircularProgressIndicator(),

           const SizedBox(height: 20,),


            Text('Latitude: $lat'),
            Text('Longitude: $long'),
            Text('data : $data'),

            // start button
            ElevatedButton(
              onPressed: () async {
                isolateLocationUpdate.startIsolates(
                  onData: (message) {
                    setState(() {
                      lat = message[0];
                      long = message[1];
                    });
                  },
                  onError: (message) {
                    dev.log(message.toString());
                  },
                );

                final jsonData = await _readFileJson();
                isolateReadFile.startIsolates(
                  input: jsonData ,
                  onData: (message) {
                    
                    setState(() {
                      data = message.toString();
                    });
                  },
                  onError: (message) {
                    dev.log("from ui load json error occured "+message.toString());
                  },

                  
                );
              },
              child: const Text('Start'),
            ),

            // button pause and resume
            ElevatedButton(
              onPressed: () async {
               isolateLocationUpdate.pause();
              },
              child: const Text('Pause'),
            ),
            
            ElevatedButton(
              onPressed: () async {
                isolateLocationUpdate.resume();
              },
              child: const Text('Resume'),
            ),


          ],
        ),
      ),
    );
  }
}

   Future<Map<String,dynamic>> _readFileJson() async{

    try{
    final fileData= await rootBundle.loadString('assets/data.json');
    dev.log("fileData $fileData");
    final jsonData= jsonDecode(fileData) as Map<String, dynamic>;
    dev.log(" jsonData $jsonData");

    return jsonData;
    }
    catch(e,s){
    dev.log("error catch read file $e $s");

    return {};

    }
   
}