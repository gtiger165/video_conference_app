import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

void main() {
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

  bool _isSoundOn = true;
  bool _isCameraOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(
              20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Nickname"),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  controller: _namaController,
                  focusNode: _nameNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan Nickname Kamu',
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text("Meeting ID"),
                SizedBox(
                  height: 8.0,
                ),
                TextField(
                  controller: _codeController,
                  focusNode: _codeNode,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Insert Meeting ID',
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                CheckboxListTile(
                    title: Text("Sound"),
                    value: _isSoundOn,
                    onChanged: (checkedStatus) {
                      setState(() {
                        _isSoundOn = checkedStatus ?? false;
                      });
                    }),
                SizedBox(
                  height: 8,
                ),
                CheckboxListTile(
                  title: Text("Camera"),
                  value: _isCameraOn,
                  onChanged: (checkedStatus) {
                    setState(() {
                      _isCameraOn = checkedStatus ?? false;
                    });
                  },
                ),
                SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text("Join"),
                    onPressed: _joinRoom,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _joinRoom() async {
    try {
      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.INVITE_ENABLED: false,
      };

      if (Platform.isAndroid) {
        featureFlags[FeatureFlagEnum.CALL_INTEGRATION_ENABLED] = false;
      }
      if (Platform.isIOS) {
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
      }

      var options = JitsiMeetingOptions(room: _codeController.text)
        ..userDisplayName = _namaController.text
        ..audioMuted = !_isSoundOn
        ..videoMuted = !_isCameraOn;

      debugPrint("jitsi options : $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join message: $message");
          },
          onConferenceJoined: (message) {
            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} terminated with message: $message");
          },
        ),
      );
    } catch (e) {
      debugPrint("error : $e");
    }
  }
}
