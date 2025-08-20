// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accept": MessageLookupByLibrary.simpleMessage("accept"),
        "applyForMicrophoneAndCameraPermissions":
            MessageLookupByLibrary.simpleMessage("youHaveANewCall"),
        "applyForMicrophonePermission":
            MessageLookupByLibrary.simpleMessage("youHaveANewCall"),
        "blurBackground":
            MessageLookupByLibrary.simpleMessage("blurBackground"),
        "cameraIsOff": MessageLookupByLibrary.simpleMessage("cameraIsOff"),
        "cameraIsOn": MessageLookupByLibrary.simpleMessage("cameraIsOn"),
        "displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions":
            MessageLookupByLibrary.simpleMessage(
                "displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions"),
        "errorInPeerBlacklist":
            MessageLookupByLibrary.simpleMessage("youHaveANewCall"),
        "hangUp": MessageLookupByLibrary.simpleMessage("hangUp"),
        "insufficientPermissions":
            MessageLookupByLibrary.simpleMessage("youHaveANewCall"),
        "invitedToAudioCall":
            MessageLookupByLibrary.simpleMessage("invitedToAudioCall"),
        "invitedToVideoCall":
            MessageLookupByLibrary.simpleMessage("invitedToVideoCall"),
        "microphoneIsOff":
            MessageLookupByLibrary.simpleMessage("microphoneIsOff"),
        "microphoneIsOn":
            MessageLookupByLibrary.simpleMessage("microphoneIsOn"),
        "needToAccessMicrophoneAndCameraPermissions":
            MessageLookupByLibrary.simpleMessage(
                "needToAccessMicrophoneAndCameraPermissions"),
        "needToAccessMicrophonePermission":
            MessageLookupByLibrary.simpleMessage("youHaveANewCall"),
        "remoteUserReject":
            MessageLookupByLibrary.simpleMessage("remote user rejected"),
        "speakerIsOff": MessageLookupByLibrary.simpleMessage("speakerIsOff"),
        "speakerIsOn": MessageLookupByLibrary.simpleMessage("speakerIsOn"),
        "switchCamera": MessageLookupByLibrary.simpleMessage("switchCamera"),
        "userBusy": MessageLookupByLibrary.simpleMessage("Other party is busy"),
        "userInCall":
            MessageLookupByLibrary.simpleMessage("User is already in a call"),
        "waiting": MessageLookupByLibrary.simpleMessage("waiting"),
        "youHaveANewCall":
            MessageLookupByLibrary.simpleMessage("You have a new call")
      };
}
