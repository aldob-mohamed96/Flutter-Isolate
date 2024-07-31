import 'dart:isolate';
import 'dart:developer' as dev;


class IsolateExcutor {

  ReceivePort? _receive;
  ReceivePort? _errorReceiver;
  Isolate? _isolate;
  Capability? _capability;


  // singletone isolate excutor

 static final IsolateExcutor _singleton = IsolateExcutor._internal();

factory IsolateExcutor() {
return _singleton;
}

IsolateExcutor._internal();

 




  Future<void> execute(Future<void> Function(IsolatesData data) entryPoint, dynamic data ,{

    required Function(dynamic message) onData,
    required Function(dynamic error) onError,
  })  async{

      if(_isolate != null)
      {
        return;
      }

        _receive = ReceivePort();
        _errorReceiver = ReceivePort();

        _receive?.listen(onData);

        _errorReceiver?.listen((message) {
          dev.log("error value $message");
          if(message is List && message.length == 2) 
          {
            onError(RemoteError('Isolate error', message[1].toString()));
          }
          else if (message != null)
          {
              onError(message);
          }else 
          {
            dev.log("error on catch isolate excute function $message");
          }

          close();
      
        });


        try 
        { 
          dev.log("isolate excute function");
          _isolate = await Isolate.spawn(
            _isolateClosure,
            onError: _errorReceiver!.sendPort ,
            onExit: _errorReceiver!.sendPort,
            errorsAreFatal:  true,
            _IsolateMessage(entryPoint: entryPoint, errorPort: _errorReceiver!.sendPort,
             isolatesData: IsolatesData(data: data, sendPort: _receive!.sendPort)
             ,
            
             )
            
          );
        }
        catch (e,s)
        { 
          
           dev.log("error on catch isolate excute function $e$s");
           onError(RemoteError('Isolate error', s.toString()));
           
           close();
        }

        



       
  }

  void pause(){
    if(_isolate != null)
    {
       dev.log('isolate paused');
       _capability =Capability();
      _isolate?.pause(_capability);
    }
  }

  void resume(){
    if(_isolate != null && _capability != null)
    {
       dev.log('isolate resumed');
      _isolate!.resume(_capability!);
    }
  }

  void close () {
     _isolate?.kill();
     _isolate=null;
    _receive?.close();
    _receive = null;
    _errorReceiver?.close();
    _errorReceiver = null;
    _capability = null;

    dev.log('isolate closed');
   
  }


}

void _isolateClosure(_IsolateMessage  message) async 
{

  try {
   dev.log('isolate closure'); 
   await message.entryPoint(message.isolatesData);
  } catch (e) 
  {
    dev.log('isolate closure error $e');
    Isolate.exit(message.errorPort, e);
  }



}


class _IsolateMessage {
  final Future<void> Function(IsolatesData data) entryPoint;

  final SendPort errorPort;
  final IsolatesData isolatesData;


  _IsolateMessage({required this.entryPoint, required this.errorPort, required this.isolatesData});
 
}

class IsolatesData {
  final dynamic data;
  final SendPort sendPort;

  IsolatesData({required this.data, required this.sendPort});


}