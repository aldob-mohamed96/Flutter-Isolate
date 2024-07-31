import 'dart:isolate';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter_isolate/isolate_read_file.dart';



class IsolateLocationUpdate {

 
  void pause () {

     final IsolateExcutor isolateExcutor = IsolateExcutor();
    
    isolateExcutor.pause();
  }


  void resume () {

     final IsolateExcutor isolateExcutor = IsolateExcutor();  
     isolateExcutor.resume();
  }

  void startIsolates({
    required Function(dynamic message) onData,
    required Function(dynamic error) onError,}
  ) async{

    final IsolateExcutor isolateExcutor = IsolateExcutor();
   


    isolateExcutor.execute( 
    entryPoint, 
    [], 
    onData: onData,
    onError: onError,);
 


   

  }
  


 


  Future<void> entryPoint(IsolatesData message) async{ 

    
        locationUpdateSimaultion().listen((event) {
         message.sendPort.send(event);
        });
   
   }

   // function get loacation updarte location

   Stream locationUpdateSimaultion() async* { 
    int i=0;
    while(i < 10){ 
      
     
      yield await Future.delayed(const Duration(seconds: 1), () {
        final Random random = Random();
        final num = random.nextDouble()+25.55554454545;
        final num1 = random.nextDouble()+24.55554454545;
          dev.log(' location $i ');
        return [num,num1];
      }); 
       i++;
   }
    yield await Future.delayed(const Duration(seconds: 2), () {
      dev.log('next location update ');
      return [0.0,0.0];
      
    } );

    yield await Future.delayed(const Duration(seconds: 4), () {
      dev.log('next location update ');
      return [0.0234234,0.0];
      
    } );
    yield await Future.delayed(const Duration(seconds: 8), () {
      dev.log('next location update last update ');
      return [0.656450,0.65650];
      
    } );
   }

}

