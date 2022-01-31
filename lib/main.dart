import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:video_conference_app/data/dao/vc_dao.dart';
import 'package:video_conference_app/data/model/video_conference_model.dart';
import 'package:video_conference_app/firebase_options.dart';
import 'package:video_conference_app/util/helper.dart';
import 'package:video_conference_app/util/vc_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Conference Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _codeController = TextEditingController();
  TextEditingController _namaController = TextEditingController();
  FocusNode _codeNode = FocusNode();
  FocusNode _nameNode = FocusNode();
  late ProgressDialog pd;
  late Stream<DatabaseEvent> stream;

  VCDao orderDao = VCDao();

  @override
  void initState() {
    super.initState();
    pd = ProgressDialog(context: context);
  }

  _onConferenceWillJoin(message) {
    debugPrint("on will join -> $message");
    pushOrder("https://meet.jit.si/${_codeController.text}");
  }

  _onConferenceJoined(message) {
    debugPrint("Joined with message: $message");
  }

  _onConferenceTerminated(message) {
    debugPrint("Terminated with message: $message");
  }

  void joinRoom() => VCUtil.joinRoom(
      room: _codeController.text,
      username: _namaController.text,
      listener: JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: StreamBuilder<DatabaseEvent>(
              stream: orderDao.getQuery().onValue,
              builder: (context, snapshot) {
                debugPrint("snapshot error -> ${snapshot.hasError}");
                if (!snapshot.hasError) {
                  if (snapshot.hasData) {
                    DatabaseEvent? event = snapshot.data;
                    print("stream database event -> ${event?.snapshot.value}");
                    if (event != null && event.snapshot.value != null) {
                      var orderData =
                          VideoConferenceModel.fromJson(event.snapshot.value);
                      bool status = orderData.status ?? false;

                      if (!status) {
                        _showMyDialog();
                      }
                    }
                  }
                }
                return Container(
                  padding: const EdgeInsets.all(
                    20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Nickname"),
                      const SizedBox(
                        height: 8.0,
                      ),
                      TextField(
                        controller: _namaController,
                        focusNode: _nameNode,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Masukkan Nickname Kamu',
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Text("Meeting ID"),
                      const SizedBox(
                        height: 8.0,
                      ),
                      TextField(
                        controller: _codeController,
                        focusNode: _codeNode,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Insert Meeting ID',
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: const Text("Join"),
                          onPressed: joinRoom,
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }

  void pushOrder(String serverUrl) {
    final data = VideoConferenceModel(
      idOrder: generateRandomNumber(),
      room: _codeController.text,
      serverUrl: serverUrl,
      status: false,
    );
    orderDao.pushOrder(data);
  }

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pemberitahuan'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Tekan tombol dibawah untuk masuk.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Join'),
              onPressed: () {
                Navigator.pop(context);
                orderDao.updateOrder(true).then((value) => joinRoom());
              },
            ),
          ],
        );
      },
    );
  }
}
