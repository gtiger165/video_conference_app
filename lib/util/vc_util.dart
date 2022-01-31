import 'dart:io';

import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class VCUtil {
  static void joinRoom(
      {String? room,
      String? username,
      String? serverUrl,
      JitsiMeetingListener? listener}) async {
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

      var options = JitsiMeetingOptions(room: room ?? "123-456")
        ..userDisplayName = username;

      if (serverUrl != null) {
        debugPrint("server url not null");
        options.serverURL = serverUrl;
      }

      debugPrint("jitsi options : $options");
      await JitsiMeet.joinMeeting(
        options,
        listener: listener,
      );
    } catch (e) {
      debugPrint("error : $e");
    }
  }
}
